# Simulation Workflow

The main reproducible workflow is `python/run_peniche_offshore_analysis.py`.

It applies the current manuscript calibration, reconstructs the payoff matrix, computes equilibrium diagnostics, regenerates the nine article figures, and writes outputs to `outputs/`. The Peniche decision-model workbook remains in `../data/` for historical traceability, but it is not the active parameter source used by this script.

The exploratory notebook is `notebooks/offshore_model_exploration.ipynb`. It preserves the interactive workflow migrated from the original workspace and uses the same Python model logic as the deterministic script.

Run from the repository root:

```powershell
python .\simulation\python\run_peniche_offshore_analysis.py
```

Additional Python scripts in `python/` provide interactive sensitivity-analysis implementations and request parameter values at runtime.

The previous deterministic R workflow is preserved under `legacy/superseded_r_workflow/`. Older exploratory scripts are preserved under `legacy/original_workspace/`.

## Generated Outputs

- `outputs/baseline_payoff_matrix.csv`
- `outputs/model_parameters.csv`
- `outputs/peniche_tourism_series.csv`
- `outputs/sensitivity_grid.csv`
- `outputs/sensitivity_summary.csv`
- `outputs/article_figure_index.csv`
- `outputs/article_figure_traceability.md`
- `outputs/article_figures/grafico1.png` through `outputs/article_figures/grafico9.png`
- `outputs/traceability/*.csv`
- `outputs/fight_preference_heatmap.png`
- `outputs/peniche_tourism_indicators.png`
