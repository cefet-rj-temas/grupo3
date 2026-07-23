# Parameter Audit for the Offshore Wind and Surf-Tourism Game Model

This note records the audit performed against the current paper draft, the `grupo3` simulation folder, and external sources checked on 2026-07-23.

## Files Checked

- `manuscript/main.tex`
- `manuscript/references.bib`
- `manuscript/generated_outputs/model_parameters.csv`
- `manuscript/generated_outputs/baseline_payoff_matrix.csv`
- `simulation/r/run_peniche_offshore_analysis.R`
- `simulation/python/*.py`
- `data/model_parameter_source_notes.md`
- `data/peniche_decision_model_sheet.tsv`

## Main Finding

The current article uses the Peniche/WSL calibration (`I=22`, `Cs=2`, `alpha=0.1`), but the mirrored CSVs currently stored in `manuscript/generated_outputs/` still reflect the older worksheet calibration (`I=10`, `Cs=3`, `alpha=0`). The paper now marks the remaining calibration choices that need author confirmation.

## Parameter Status

| Parameter | Current paper value/use | Audit status |
| --- | --- | --- |
| `I` | `22`, order-of-magnitude surf-related GVA benchmark | Supported by the WSL/ISEG material and cited in the paper. |
| `R` | `100`, normalized offshore gross return | Treated as a modelling scale, with Portuguese offshore investment magnitude cited. |
| `LR` | `20`, delay/concession/reduction in offshore return | Plausible as a scenario value, but not independently estimated; marked for verification. |
| `Cs` | `2`, offshore litigation/transaction cost | Not independently sourced; marked for verification. |
| `Ca` | varied from `0` to `I` and in sensitivity ranges | Methodological sensitivity parameter; implementation should be checked against scripts. |
| `G` | varied over compensation grids | Methodological sensitivity parameter; compensation design is supported conceptually by legal and tourism sources. |
| `P` | probability offshore side prevails | Reduced-form uncertainty parameter; legal/institutional interpretation remains open and is marked for verification. |
| `alpha` | `0.1` residual contestation-cost share | Not independently sourced; marked for verification. |
| `L` | stylized impact scenarios of 20%, 40%, and 90% of `I` | Scenario design, not empirical hydrodynamic estimates; high-impact wording was softened and marked. |

## Sources Added or Checked

- WSL/ISEG economic-impact study page: <https://www.iseg.ulisboa.pt/estudar/trabalhos-finais-de-mestrado/cemp/1410823742297037/>
- Universidade de Lisboa repository record: <https://repositorio.ulisboa.pt/entities/publication/95f44840-8f87-4b40-8584-de76f5d89a91>
- Diario da Republica, Decree-Law No. 140/99: <https://diariodarepublica.pt/dr/detalhe/decreto-lei/140-1999-531828>
- ICNF compensatory-measures guidance: <https://www.icnf.pt/api/file/doc/3401bfd118136d67>
- IberBlue Wind/ISQ offshore-investment announcement: <https://www.iberbluewind.com/news/iberblue-wind-and-isq-partner-to-promote-offshore-wind-in-portugal>
- Macedo Vitorino offshore renewable-energy zoning briefing: <https://www.macedovitorino.com/en/knowledge/insights/Offshore-renewable-Energies-Zoning-Plan-allocates-Portuguese-seabed-for-Offshore-wind-farms/6654/>
- Clean Air Task Force offshore-wind delay note: <https://www.catf.us/2025/01/rough-seas-offshore-wind-hard-look-causes-delay/>
- Resources for the Future permitting/litigation delay note: <https://www.resources.org/archives/delays-to-wind-and-solar-energy-projects-permitting-and-litigation-are-not-the-only-obstacles/>

## Remaining Work

- Regenerate the figures and CSV traceability files from the same parameterization used in the paper.
- Confirm whether Player 2 should formally include WSL or whether WSL should be treated only as an empirical source/proxy.
- Confirm whether `P` means judicial success narrowly or broader institutional success.
- Confirm the intended calibration basis for `LR=20`, `Cs=2`, and `alpha=0.1`.
