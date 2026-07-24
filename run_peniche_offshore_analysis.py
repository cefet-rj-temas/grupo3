#!/usr/bin/env python
"""Regenerate the Peniche offshore wind versus surf-tourism model outputs.

This is the deterministic Python workflow aligned with the exploratory
Jupyter notebook and the current manuscript calibration.
"""

from __future__ import annotations

from pathlib import Path
import shutil

import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.patches import Patch


PROJECT_ROOT = Path(__file__).resolve().parent
OUTPUT_DIR = PROJECT_ROOT
FIGURE_DIR = OUTPUT_DIR / "article_figures"
TRACE_DIR = OUTPUT_DIR / "traceability"

COLOR_MAP = {
    "Implement / Accept": "#4CAF50",
    "Implement / Fight": "#F44336",
    "Withdraw / Accept": "#9E9E9E",
    "Withdraw / Fight": "#607D8B",
    "Absence of Pure Equilibrium": "#FFC107",
}
EQ_LEVELS = list(COLOR_MAP)
ARTICLE_LEGEND_LEVELS = [
    "Implement / Accept",
    "Absence of Pure Equilibrium",
    "Implement / Fight",
]

plt.rcParams.update(
    {
        "font.size": 12,
        "axes.titlesize": 14,
        "axes.labelsize": 13,
        "xtick.labelsize": 11,
        "ytick.labelsize": 11,
        "legend.fontsize": 11,
        "legend.title_fontsize": 12,
    }
)

PARAMS = {
    "R": 100.0,
    "LR": 20.0,
    "Cs": 2.0,
    "I": 22.0,
    "L": 4.4,
    "alpha": 0.1,
    "Ca": 3.0,
    "G": 4.4,
    "P": 0.5,
}
IMPACT_SCENARIOS = {
    "low_impact": 0.2 * PARAMS["I"],
    "medium_impact": 0.4 * PARAMS["I"],
    "high_impact": 0.9 * PARAMS["I"],
}


def ensure_output_dirs() -> None:
    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    TRACE_DIR.mkdir(parents=True, exist_ok=True)


def equilibrium_class(p: dict[str, np.ndarray | float]) -> np.ndarray:
    g1 = p["P"] * (p["R"] - p["LR"] - p["Cs"] - p["G"]) + (1 - p["P"]) * (-p["Cs"])
    g2 = (1 - p["P"]) * (p["I"] - p["Ca"]) + p["P"] * (p["I"] - p["L"] + p["G"] - p["Ca"])

    n_ia = (p["R"] >= 0) & ((p["I"] - p["L"]) >= g2)
    n_if = (g1 >= 0) & (g2 >= (p["I"] - p["L"]))
    n_wa = (0 >= p["R"]) & (p["I"] >= (p["I"] - p["alpha"] * p["Ca"]))
    n_wf = (0 >= g1) & ((p["I"] - p["alpha"] * p["Ca"]) >= p["I"])

    result = np.full(np.size(g1), "Absence of Pure Equilibrium", dtype=object)
    result[np.asarray(n_wf).reshape(-1)] = "Withdraw / Fight"
    result[(np.asarray(n_wa) & ~np.asarray(n_wf)).reshape(-1)] = "Withdraw / Accept"
    result[(np.asarray(n_if) & ~np.asarray(n_wa) & ~np.asarray(n_wf)).reshape(-1)] = "Implement / Fight"
    result[np.asarray(n_ia).reshape(-1)] = "Implement / Accept"
    return result.reshape(np.shape(g1))


def grid_equilibria(
    params: dict[str, float],
    x_name: str,
    x_values: np.ndarray,
    y_name: str,
    y_values: np.ndarray,
) -> tuple[pd.DataFrame, np.ndarray]:
    x_mesh, y_mesh = np.meshgrid(x_values, y_values, indexing="ij")
    p: dict[str, np.ndarray | float] = params.copy()
    p[x_name] = x_mesh
    p[y_name] = y_mesh
    z = equilibrium_class(p)
    rows = pd.DataFrame({x_name: x_mesh.ravel(), y_name: y_mesh.ravel(), "equilibrium": z.ravel()})
    return rows, z


def area_evolution(
    params: dict[str, float],
    varying_name: str,
    varying_values: np.ndarray,
    x_values: np.ndarray | None = None,
    y_values: np.ndarray | None = None,
) -> pd.DataFrame:
    if x_values is None:
        x_values = np.linspace(0, 1, 100)
    if y_values is None:
        y_values = np.linspace(0, 1.5 * params["L"], 100)

    rows = []
    for value in varying_values:
        p = params.copy()
        p[varying_name] = float(value)
        _, z = grid_equilibria(p, "P", x_values, "G", y_values)
        total = z.size
        for eq in EQ_LEVELS:
            rows.append(
                {
                    "variable": varying_name,
                    "value": value,
                    "equilibrium": eq,
                    "area_percent": (z == eq).sum() / total * 100,
                }
            )
    return pd.DataFrame(rows)


def plot_heatmap(
    rows: pd.DataFrame,
    z: np.ndarray,
    x_name: str,
    y_name: str,
    title: str,
    xlab: str,
    ylab: str,
    filename: str,
) -> None:
    x_values = np.sort(rows[x_name].unique())
    y_values = np.sort(rows[y_name].unique())
    z_int = np.vectorize(lambda eq: EQ_LEVELS.index(eq))(z)
    cmap = mcolors.ListedColormap([COLOR_MAP[eq] for eq in EQ_LEVELS])
    norm = mcolors.BoundaryNorm(np.arange(len(EQ_LEVELS) + 1) - 0.5, cmap.N)

    fig, ax = plt.subplots(figsize=(8, 6))
    ax.pcolormesh(x_values, y_values, z_int.T, cmap=cmap, norm=norm, shading="auto")
    # Figure identification is kept in the call title and LaTeX caption; article PNGs omit embedded titles.
    ax.set_xlabel(xlab, fontfamily="serif")
    ax.set_ylabel(ylab, fontfamily="serif")
    ax.grid(True, linestyle="--", alpha=0.35)
    handles = [
        Patch(facecolor=COLOR_MAP[eq], edgecolor="black", label=eq)
        for eq in ARTICLE_LEGEND_LEVELS
        if eq in set(rows["equilibrium"])
    ]
    ax.legend(
        handles=handles,
        title="Nash Equilibrium",
        loc="upper center",
        bbox_to_anchor=(0.5, -0.16),
        ncol=3,
        frameon=True,
        columnspacing=1.3,
        handletextpad=0.5,
        borderaxespad=0.8,
    )
    fig.tight_layout(rect=(0, 0.04, 1, 1))
    fig.savefig(FIGURE_DIR / filename, dpi=300, bbox_inches="tight")
    plt.close(fig)


def plot_area(rows: pd.DataFrame, title: str, xlab: str, filename: str) -> None:
    fig, ax = plt.subplots(figsize=(10, 6))
    for eq in EQ_LEVELS:
        eq_rows = rows[rows["equilibrium"] == eq]
        if eq_rows["area_percent"].max() > 0:
            ax.plot(
                eq_rows["value"],
                eq_rows["area_percent"],
                color=COLOR_MAP[eq],
                marker="o",
                linewidth=2.5,
                markersize=5,
                label=eq,
            )
    # Figure identification is kept in the call title and LaTeX caption; article PNGs omit embedded titles.
    ax.set_xlabel(xlab, fontfamily="serif")
    ax.set_ylabel("Area in the P vs G scenario grid (%)", fontfamily="serif")
    ax.set_ylim(-5, 105)
    ax.grid(True, linestyle="--", alpha=0.6)
    handles, labels = ax.get_legend_handles_labels()
    legend_by_label = dict(zip(labels, handles))
    ordered_labels = [eq for eq in ARTICLE_LEGEND_LEVELS if eq in legend_by_label]
    ax.legend(
        [legend_by_label[label] for label in ordered_labels],
        ordered_labels,
        title="Nash Equilibrium",
        loc="upper center",
        bbox_to_anchor=(0.5, -0.16),
        ncol=3,
        frameon=True,
        columnspacing=1.3,
        handletextpad=0.5,
        borderaxespad=0.8,
    )
    fig.tight_layout(rect=(0, 0.04, 1, 1))
    fig.savefig(FIGURE_DIR / filename, dpi=300, bbox_inches="tight")
    plt.close(fig)


def copy_article_figure(source_name: str, article_name: str) -> None:
    shutil.copyfile(FIGURE_DIR / source_name, FIGURE_DIR / article_name)


def write_baseline_outputs() -> None:
    params_tbl = pd.DataFrame({"symbol": list(PARAMS), "value": list(PARAMS.values())})
    params_tbl.to_csv(OUTPUT_DIR / "model_parameters.csv", index=False)

    g1 = PARAMS["P"] * (PARAMS["R"] - PARAMS["LR"] - PARAMS["Cs"] - PARAMS["G"]) + (1 - PARAMS["P"]) * (-PARAMS["Cs"])
    g2 = (1 - PARAMS["P"]) * (PARAMS["I"] - PARAMS["Ca"]) + PARAMS["P"] * (PARAMS["I"] - PARAMS["L"] + PARAMS["G"] - PARAMS["Ca"])

    baseline = pd.DataFrame(
        {
            "offshore_action": ["Implement", "Implement", "Withdraw", "Withdraw"],
            "surf_action": ["Accept", "Fight", "Accept", "Fight"],
            "offshore_payoff": [PARAMS["R"], g1, 0, 0],
            "surf_payoff": [PARAMS["I"] - PARAMS["L"], g2, PARAMS["I"], PARAMS["I"] - PARAMS["alpha"] * PARAMS["Ca"]],
        }
    )
    baseline["total_payoff"] = baseline["offshore_payoff"] + baseline["surf_payoff"]
    baseline["better_for_offshore"] = [
        baseline.offshore_payoff[0] >= baseline.offshore_payoff[2],
        baseline.offshore_payoff[1] >= baseline.offshore_payoff[3],
        baseline.offshore_payoff[2] >= baseline.offshore_payoff[0],
        baseline.offshore_payoff[3] >= baseline.offshore_payoff[1],
    ]
    baseline["better_for_surf"] = [
        baseline.surf_payoff[0] >= baseline.surf_payoff[1],
        baseline.surf_payoff[1] >= baseline.surf_payoff[0],
        baseline.surf_payoff[2] >= baseline.surf_payoff[3],
        baseline.surf_payoff[3] >= baseline.surf_payoff[2],
    ]
    baseline["is_nash"] = baseline["better_for_offshore"] & baseline["better_for_surf"]
    baseline["is_pareto_max"] = baseline["total_payoff"] == baseline["total_payoff"].max()
    baseline.to_csv(OUTPUT_DIR / "baseline_payoff_matrix.csv", index=False)


def write_supporting_sensitivity_outputs() -> None:
    grid = pd.MultiIndex.from_product(
        [
            np.arange(0.1, 1.0, 0.1),
            np.arange(0, 1.5 * PARAMS["I"] + 1, 1),
            np.arange(0, PARAMS["I"] + 1, 1),
            list(IMPACT_SCENARIOS.values()),
        ],
        names=["P", "G", "Ca", "L"],
    ).to_frame(index=False)
    grid["R"] = PARAMS["R"]
    grid["LR"] = PARAMS["LR"]
    grid["Cs"] = PARAMS["Cs"]
    grid["I"] = PARAMS["I"]
    grid["alpha"] = PARAMS["alpha"]
    grid["offshore_conflict_payoff"] = grid["P"] * (grid["R"] - grid["LR"] - grid["Cs"] - grid["G"]) + (1 - grid["P"]) * (-grid["Cs"])
    grid["surf_conflict_payoff"] = (1 - grid["P"]) * (grid["I"] - grid["Ca"]) + grid["P"] * (grid["I"] - grid["L"] + grid["G"] - grid["Ca"])
    grid["surf_accept_payoff"] = grid["I"] - grid["L"]
    grid["fight_minus_accept"] = grid["surf_conflict_payoff"] - grid["surf_accept_payoff"]
    grid["offshore_implements"] = grid["offshore_conflict_payoff"] > 0
    grid["surf_prefers_fight"] = grid["surf_conflict_payoff"] >= grid["surf_accept_payoff"]
    grid.to_csv(OUTPUT_DIR / "sensitivity_grid.csv", index=False)

    summary = (
        grid.groupby(["P", "G"], as_index=False)[["surf_prefers_fight", "offshore_implements"]]
        .mean()
        .rename(
            columns={
                "surf_prefers_fight": "share_surf_prefers_fight",
                "offshore_implements": "share_offshore_implements",
            }
        )
    )
    summary.to_csv(OUTPUT_DIR / "sensitivity_summary.csv", index=False)


def write_article_figures() -> None:
    p_values = np.linspace(0, 1, 100)
    low = PARAMS.copy()
    low["L"] = IMPACT_SCENARIOS["low_impact"]
    g_values_low = np.linspace(0, 1.5 * low["L"], 100)

    pxg_rows, pxg_z = grid_equilibria(low, "G", g_values_low, "P", p_values)
    pxg_rows.to_csv(TRACE_DIR / "figure_01_probability_compensation_low_impact.csv", index=False)
    # Figure 1: P x G equilibrium heatmap, low-impact scenario.
    plot_heatmap(
        pxg_rows,
        pxg_z,
        "G",
        "P",
        "Sensitivity Analysis: Probability (P) vs. Compensation (G)",
        "Financial Compensation Offered (G)",
        "Probability of Offshore Institutional Success (P)",
        "probability_compensation_low_impact.png",
    )
    copy_article_figure("probability_compensation_low_impact.png", "grafico1.png")

    ca_variations = np.arange(-50, 55, 5)
    for slug, value in IMPACT_SCENARIOS.items():
        p = PARAMS.copy()
        p["L"] = value
        area = area_evolution(
            p,
            "Ca",
            PARAMS["Ca"] * (1 + ca_variations / 100),
            y_values=np.linspace(0, 1.5 * p["L"], 100),
        )
        area["variation_percent"] = np.repeat(ca_variations, len(EQ_LEVELS))
        area.to_csv(TRACE_DIR / f"stakeholder_cost_area_{slug}.csv", index=False)
        # Figures 2-4: P x G x Ca area evolution by impact scenario.
        plot_area(
            area.assign(value=area["variation_percent"]),
            f"Evolution of Equilibrium Areas by Stakeholder Cost - {slug.replace('_', ' ').title()}",
            "Variation of Stakeholder Cost Ca (%)",
            f"stakeholder_cost_area_{slug}.png",
        )
    copy_article_figure("stakeholder_cost_area_low_impact.png", "grafico2.png")
    copy_article_figure("stakeholder_cost_area_medium_impact.png", "grafico3.png")
    copy_article_figure("stakeholder_cost_area_high_impact.png", "grafico4.png")

    l_area = area_evolution(
        PARAMS,
        "L",
        np.linspace(0, 0.9 * PARAMS["I"], 21),
        y_values=np.linspace(0, 1.5 * 0.9 * PARAMS["I"], 100),
    )
    l_area.to_csv(TRACE_DIR / "expected_local_loss_area.csv", index=False)
    # Figure 5: P x G x L area evolution.
    plot_area(l_area, "Evolution of Equilibrium Areas by Expected Local Loss", "Expected Local Loss L", "expected_local_loss_area.png")
    copy_article_figure("expected_local_loss_area.png", "grafico5.png")

    gl_rows, gl_z = grid_equilibria(
        PARAMS,
        "G",
        np.linspace(0, 1.5 * PARAMS["I"], 100),
        "L",
        np.linspace(0, 0.9 * PARAMS["I"], 100),
    )
    gl_rows.to_csv(TRACE_DIR / "compensation_loss_heatmap.csv", index=False)
    # Figure 6: G x L equilibrium heatmap.
    plot_heatmap(
        gl_rows,
        gl_z,
        "G",
        "L",
        "Strategic Frontier: Compensation (G) vs. Local Loss (L)",
        "Financial Compensation Offered (G)",
        "Expected Local Loss (L)",
        "compensation_loss_heatmap.png",
    )
    copy_article_figure("compensation_loss_heatmap.png", "grafico6.png")

    lr_area = area_evolution(
        low,
        "LR",
        np.linspace(0, PARAMS["R"], 21),
        y_values=np.linspace(0, 1.5 * low["L"], 100),
    )
    lr_area.to_csv(TRACE_DIR / "delay_cost_area_low_impact.csv", index=False)
    # Figure 7: P x G x LR area evolution, low-impact scenario.
    plot_area(lr_area, "Evolution of Equilibrium Areas by Delay Cost - Low Impact", "Delay Cost LR", "delay_cost_area_low_impact.png")
    copy_article_figure("delay_cost_area_low_impact.png", "grafico7.png")

    for slug in ["low_impact", "high_impact"]:
        p = PARAMS.copy()
        p["L"] = IMPACT_SCENARIOS[slug]
        p["G"] = p["L"]
        cost_rows, cost_z = grid_equilibria(
            p,
            "Ca",
            np.linspace(0, PARAMS["I"], 100),
            "Cs",
            np.linspace(0, PARAMS["R"], 100),
        )
        cost_rows.to_csv(TRACE_DIR / f"stakeholder_consortium_cost_heatmap_{slug}.csv", index=False)
        # Figures 8-9: Ca x Cs equilibrium heatmaps for low- and high-impact scenarios.
        plot_heatmap(
            cost_rows,
            cost_z,
            "Ca",
            "Cs",
            f"Legal-Cost Asymmetry: {slug.replace('_', ' ').title()}",
            "Stakeholder Cost (Ca)",
            "Offshore Consortium Cost (Cs)",
            f"stakeholder_consortium_cost_heatmap_{slug}.png",
        )
    copy_article_figure("stakeholder_consortium_cost_heatmap_low_impact.png", "grafico8.png")
    copy_article_figure("stakeholder_consortium_cost_heatmap_high_impact.png", "grafico9.png")


def write_figure_index() -> None:
    figure_index = pd.DataFrame(
        {
            "manuscript_file": [f"images/grafico{i}.png" for i in range(1, 10)],
            "artifact_file": [f"article_figures/grafico{i}.png" for i in range(1, 10)],
            "source_traceability": [
                "traceability/figure_01_probability_compensation_low_impact.csv",
                "traceability/stakeholder_cost_area_low_impact.csv",
                "traceability/stakeholder_cost_area_medium_impact.csv",
                "traceability/stakeholder_cost_area_high_impact.csv",
                "traceability/expected_local_loss_area.csv",
                "traceability/compensation_loss_heatmap.csv",
                "traceability/delay_cost_area_low_impact.csv",
                "traceability/stakeholder_consortium_cost_heatmap_low_impact.csv",
                "traceability/stakeholder_consortium_cost_heatmap_high_impact.csv",
            ],
            "description": [
                "P x G equilibrium heatmap, low-impact scenario.",
                "P x G x Ca area evolution, low-impact scenario.",
                "P x G x Ca area evolution, medium-impact scenario.",
                "P x G x Ca area evolution, high-impact scenario.",
                "P x G x L area evolution.",
                "G x L equilibrium heatmap.",
                "P x G x LR area evolution, low-impact scenario.",
                "Ca x Cs equilibrium heatmap, low-impact scenario.",
                "Ca x Cs equilibrium heatmap, high-impact scenario.",
            ],
        }
    )
    figure_index.to_csv(OUTPUT_DIR / "article_figure_index.csv", index=False)

    lines = [
        "# Article Figure Traceability",
        "",
        "The active workflow is `run_peniche_offshore_analysis.py`. It uses the same deterministic Python model implemented in `offshore_model_exploration.ipynb` and writes the manuscript figures to `article_figures/`.",
        "",
        "The Jupyter notebook is kept as an active exploratory interface. The Python script is the deterministic workflow for regenerating article figures and CSV traceability files.",
        "",
        "| Manuscript figure | Artifact figure | Traceability data | Description |",
        "|---|---|---|---|",
    ]
    for _, row in figure_index.iterrows():
        lines.append(
            f"| `{row['manuscript_file']}` | `{row['artifact_file']}` | `{row['source_traceability']}` | {row['description']} |"
        )
    lines.extend(
        [
            "",
            "Baseline parameters: `R=100`, `LR=20`, `Cs=2`, `I=22`, `L=4.4`, `alpha=0.1`, `Ca=3`, `G=4.4`, and `P=0.5`. Low, medium, and high impact scenarios set `L` to 20%, 40%, and 90% of `I`, respectively.",
        ]
    )
    (OUTPUT_DIR / "article_figure_traceability.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    ensure_output_dirs()
    write_baseline_outputs()
    write_supporting_sensitivity_outputs()
    write_article_figures()
    write_figure_index()
    print(f"Outputs written to: {OUTPUT_DIR}")
    print(f"Article figures written to: {FIGURE_DIR}")


if __name__ == "__main__":
    main()
