# Simulation Workflow

The main reproducible workflow is `r/run_peniche_offshore_analysis.R`.

It reads the Peniche decision-model workbook from `../data/peniche_decision_model_workbook.xlsx`, reconstructs the payoff matrix, computes equilibrium diagnostics, and writes outputs to `outputs/`.

Run from the repository root:

```powershell
Rscript .\simulation\r\run_peniche_offshore_analysis.R
```

Python scripts in `python/` provide additional sensitivity-analysis implementations. They are interactive scripts and request parameter values at runtime.

Older exploratory scripts and notebooks are preserved under `legacy/original_workspace/`.

## Generated Outputs

- `outputs/baseline_payoff_matrix.csv`
- `outputs/model_parameters.csv`
- `outputs/peniche_tourism_series.csv`
- `outputs/sensitivity_grid.csv`
- `outputs/sensitivity_summary.csv`
- `outputs/fight_preference_heatmap.png`
- `outputs/peniche_tourism_indicators.png`
