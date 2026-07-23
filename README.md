# Offshore Wind and Surf-Tourism Game Model Artifact

This repository contains the organized data, simulation code, parameter audit, and supporting documentation for the article **"Negotiating Offshore Wind and Surf-Tourism Interests: A Peniche-Based Game-Theoretic Model"**.

The manuscript itself is maintained outside this repository in the paper working directory. This artifact repository should not contain a duplicate manuscript copy. Files that are not part of the active model execution, parameter audit, or article support material were preserved under `legacy/original_workspace/`.

## Repository Map

### Root

- `.gitignore` - repository ignore rules.
- `LICENSE` - repository license.
- `README.md` - this repository guide.

### Simulation

- `simulation/r/run_peniche_offshore_analysis.R` - main reproducible R workflow.
- `simulation/README.md` - simulation folder guide.
- `simulation/python/probability_compensation_heatmap.py` - Python implementation of the `P x G` heatmap.
- `simulation/python/compensation_sensitivity.py` - Python compensation-sensitivity script.
- `simulation/python/stakeholder_cost_area_sensitivity.py` - stakeholder-cost area-sensitivity script.
- `simulation/python/consortium_cost_area_sensitivity.py` - consortium-cost area-sensitivity script.
- `simulation/python/delay_loss_area_sensitivity.py` - delay-loss area-sensitivity script.
- `simulation/python/withdrawal_cost_share_area_sensitivity.py` - withdrawal-cost-share area-sensitivity script.
- `simulation/requirements.txt` - Python package requirements.
- `simulation/offshore_surf_tourism_game.Rproj` - RStudio project file.
- `simulation/outputs/baseline_payoff_matrix.csv` - regenerated baseline payoff matrix.
- `simulation/outputs/model_parameters.csv` - regenerated parameter table.
- `simulation/outputs/peniche_tourism_series.csv` - regenerated Peniche tourism series.
- `simulation/outputs/sensitivity_grid.csv` - regenerated sensitivity grid.
- `simulation/outputs/sensitivity_summary.csv` - regenerated sensitivity summary.
- `simulation/outputs/fight_preference_heatmap.png` - regenerated fight-preference heatmap.
- `simulation/outputs/peniche_tourism_indicators.png` - regenerated tourism-indicator figure.

### Data

- `data/peniche_decision_model_workbook.xlsx` - source workbook for the abstract decision model.
- `data/README.md` - data folder guide.
- `data/peniche_decision_model_sheet.tsv` - extracted decision-model worksheet.
- `data/peniche_municipal_indicators.pdf` - Peniche municipal indicators.
- `data/peniche_municipal_profile.pdf` - additional Peniche municipal profile.
- `data/peniche_local_surf_economy_neves_2021.pdf` - Peniche surf-economy thesis.
- `data/ericeira_world_surfing_reserve_impact_2022.pdf` - Ericeira World Surfing Reserve impact study.
- `data/wsl_portugal_economic_impact.pdf` - WSL Portugal economic-impact source.
- `data/model_parameter_source_notes.md` - English consolidation of qualitative notes for model parameters.

### Documentation

- `documentation/parameter_audit.md` - audit of model parameters, sources, and remaining verification points.
- `documentation/README.md` - documentation folder guide.
- `documentation/supplementary_notes.md` - support material moved out of the article appendix.

### References

- `references/curated_reference_inventory.md` - working inventory of curated literature and support sources.
- `references/README.md` - references folder guide.

### Legacy

- `legacy/original_workspace/` - previous working tree, including older article drafts, raw vault material, old folder names, and files not needed in the active submission package.
- `legacy/build_artifacts/` - auxiliary build files kept only for historical traceability.

## Run the Main Simulation Workflow

From the repository root:

```powershell
Rscript .\simulation\r\run_peniche_offshore_analysis.R
```

The workflow reads `data/peniche_decision_model_workbook.xlsx` and writes regenerated outputs to `simulation/outputs/`.

## Current Audit Note

The article currently uses a Peniche/WSL calibration (`I=22`, `Cs=2`, `alpha=0.1`). The regenerated outputs in `simulation/outputs/` still reflect the workbook calibration unless the workbook itself is updated. This parameter status is documented in `documentation/parameter_audit.md`.
