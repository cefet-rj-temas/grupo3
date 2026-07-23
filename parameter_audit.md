# Parameter Audit for the Offshore Wind and Surf-Tourism Game Model

This note records the audit performed against the current paper draft, the `grupo3` simulation folder, and external sources checked on 2026-07-23.

## Files Checked

- `manuscript/main.tex`
- `manuscript/references.bib`
- `model_parameters.csv`
- `baseline_payoff_matrix.csv`
- `run_peniche_offshore_analysis.py`
- `offshore_model_exploration.ipynb`
- `model_parameter_source_notes.md`
- `data/peniche_decision_model_sheet.tsv`

## Main Finding

The current article uses a Peniche/WSL order-of-magnitude calibration. The active Python simulation workflow now applies the manuscript calibration directly before writing outputs. The former worksheet values (`I=10`, `Cs=3`, `alpha=0`) are retained only as historical source material in the workbook and legacy files; they are not the active article calibration.

## Parameter Status

| Parameter | Current paper value/use | Audit status |
| --- | --- | --- |
| `I` | `22`, order-of-magnitude surf-related GVA benchmark | Supported by the WSL/ISEG material and cited in the paper. |
| `R` | `100`, normalized offshore gross return | Treated as a modelling scale, with Portuguese offshore investment magnitude cited. |
| `LR` | `20`, delay/concession/reduction in offshore return | Normalized scenario value used for sensitivity interpretation; not an observed estimate. |
| `Cs` | `2`, offshore litigation/transaction cost | Normalized scenario value used for sensitivity interpretation; not an observed estimate. |
| `Ca` | varied from `0` to `I` and in sensitivity ranges | Methodological sensitivity parameter implemented in the active workflow. |
| `G` | varied over compensation grids | Methodological sensitivity parameter; compensation design is supported conceptually by legal and tourism sources. |
| `P` | probability offshore side prevails institutionally | Reduced-form uncertainty parameter covering licensing, legal, technical-contestation, and implementation dimensions. |
| `alpha` | `0.1` residual contestation-cost share | Normalized scenario value used for sensitivity interpretation; not an observed estimate. |
| `L` | stylized impact scenarios of 20%, 40%, and 90% of `I` | Scenario design, not empirical hydrodynamic estimates. |

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

- Keep the generated outputs synchronized whenever the manuscript calibration changes.
- Treat Player 2 as a hypothetical surf-tourism coalition; WSL is an empirical reference and possible coalition member, not a required formal representative.
- Treat `P` as broader institutional success rather than judicial success alone.
- Report `LR=20`, `Cs=2`, and `alpha=0.1` as normalized scenario values, not as independently observed estimates.
