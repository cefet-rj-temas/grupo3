# Code Workflow

O script principal é [`peniche_offshore_analysis.R`](./r_scripts/peniche_offshore_analysis.R). Ele foi escrito para sustentar diretamente a metodologia do artigo em [`main.tex`](../Paper/main.tex) e a formulação em [`Game theoretic Model.tex`](../references/source_files/Paper_Game_theoretic_Model.tex).


- Scripts em R:
    - `sensitivity_analysis_G.R`: Análise de sensibilidade para o ganho político/estratégico (G).
    - `sensitivity_analysis_P.R`: Análise de sensibilidade para a probabilidade de vitória jurídica (P).
    - `sensitivity_analysis_PxG.R`: Análise combinada de P e G.
- Scripts em Python:
    - `sensitivity_analysis_Ca_area.py`, `sensitivity_analysis_Cs_area.py`, `sensitivity_analysis_LR_area.py`, `sensitivity_analysis_alpha_area.py`, `sensitivity_analysis_G.py`, `sensitivity_analysis_PxG.py`

## Requisitos

### R
- `readxl`
- `dplyr`
- `tidyr`
- `purrr`
- `ggplot2`
- `stringr`

### Python
Os requisitos para os scripts Python estão listados no arquivo `requirements.txt`:
- `pandas`
- `numpy`
- `matplotlib`
- `seaborn`

## Execução

No diretório raiz do projeto:

```powershell
Rscript .\code\peniche_offshore_analysis.R
```

Para os scripts Python:
```powershell
python .\code\sensitivity_analysis_XXXXXXX.py
```