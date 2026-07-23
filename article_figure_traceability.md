# Article Figure Traceability

The active workflow is `run_peniche_offshore_analysis.py`. It uses the same deterministic Python model implemented in `offshore_model_exploration.ipynb` and writes the manuscript figures to `article_figures/`.

The Jupyter notebook is kept as an active exploratory interface. The Python script is the deterministic workflow for regenerating article figures and CSV traceability files.

| Manuscript figure | Artifact figure | Traceability data | Description |
|---|---|---|---|
| `images/grafico1.png` | `article_figures/grafico1.png` | `traceability/figure_01_probability_compensation_low_impact.csv` | P x G equilibrium heatmap, low-impact scenario. |
| `images/grafico2.png` | `article_figures/grafico2.png` | `traceability/stakeholder_cost_area_low_impact.csv` | P x G x Ca area evolution, low-impact scenario. |
| `images/grafico3.png` | `article_figures/grafico3.png` | `traceability/stakeholder_cost_area_medium_impact.csv` | P x G x Ca area evolution, medium-impact scenario. |
| `images/grafico4.png` | `article_figures/grafico4.png` | `traceability/stakeholder_cost_area_high_impact.csv` | P x G x Ca area evolution, high-impact scenario. |
| `images/grafico5.png` | `article_figures/grafico5.png` | `traceability/expected_local_loss_area.csv` | P x G x L area evolution. |
| `images/grafico6.png` | `article_figures/grafico6.png` | `traceability/compensation_loss_heatmap.csv` | G x L equilibrium heatmap. |
| `images/grafico7.png` | `article_figures/grafico7.png` | `traceability/delay_cost_area_low_impact.csv` | P x G x LR area evolution, low-impact scenario. |
| `images/grafico8.png` | `article_figures/grafico8.png` | `traceability/stakeholder_consortium_cost_heatmap_low_impact.csv` | Ca x Cs equilibrium heatmap, low-impact scenario. |
| `images/grafico9.png` | `article_figures/grafico9.png` | `traceability/stakeholder_consortium_cost_heatmap_high_impact.csv` | Ca x Cs equilibrium heatmap, high-impact scenario. |

Baseline parameters: `R=100`, `LR=20`, `Cs=2`, `I=22`, `L=4.4`, `alpha=0.1`, `Ca=3`, `G=4.4`, and `P=0.5`. Low, medium, and high impact scenarios set `L` to 20%, 40%, and 90% of `I`, respectively.
