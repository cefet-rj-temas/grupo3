# Code Workflow

O script principal é [`peniche_offshore_analysis.R`](/c:/Git/temas/grupo3/code/peniche_offshore_analysis.R). Ele foi escrito para sustentar diretamente a metodologia do artigo em [`main.tex`](/c:/Git/temas/grupo3/Paper/main.tex) e a formulação em [`Game theoretic Model.tex`](/c:/Git/temas/grupo3/Paper/Game%20theoretic%20Model.tex).

## O que o script faz

1. Lê a aba `Problema de Decisão Abstrato` de `Dados Peniche.xlsx`.
2. Reconstrói a matriz de payoff do problema offshore versus surfe/turismo.
3. Calcula payoffs esperados, células de Nash e máximo de Pareto.
4. Lê a aba `Dados Peniche` e organiza as séries de turismo usadas como referência de ordem de grandeza.
5. Executa uma análise de sensibilidade sobre `P`, `G`, `Ca` e `L`.
6. Exporta tabelas `.csv` e figuras `.png` para [`Paper/generated`](/c:/Git/temas/grupo3/Paper/generated).

## Pacotes R necessários

- `readxl`
- `dplyr`
- `tidyr`
- `purrr`
- `ggplot2`
- `stringr`

## Execução

No diretório raiz do projeto:

```powershell
Rscript .\code\peniche_offshore_analysis.R
```

## Conexão com o artigo

O artigo usa o código para sustentar três pontos metodológicos:

- A planilha não é tratada como base econométrica completa, mas como calibração transparente do problema de decisão.
- A análise exploratória mostra quando a coalizão do surfe prefere aceitar ou lutar, dado o desenho de compensação e o custo de mobilização.
- As séries de Peniche fornecem ordem de grandeza para justificar que a perda potencial do turismo do surfe é economicamente relevante.

## Observação

Neste ambiente, `Rscript` não está disponível no `PATH`, então o código foi entregue documentado e pronto para execução, mas não pôde ser rodado aqui.
