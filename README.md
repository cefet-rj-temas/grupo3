# Grupo 3

Repositório de trabalho para produção do artigo sobre conflito, negociação e modelagem entre energia eólica offshore e interesses de surfe/turismo em Portugal, com motivação territorial em Ericeira e calibração de ordem de grandeza em Peniche.

## Objetivo do repositório

O objetivo atual é viabilizar a produção do artigo, consolidando:

- o texto principal em LaTeX;
- a formulação do modelo de decisão;
- a análise exploratória em R;
- a base de referências e dados já triada;
- o descarte controlado do material considerado não relevante.

## Planejamento de atividades

As próximas atividades recomendadas para fechar o artigo são:

1. Revisar o argumento central do artigo e alinhar título, resumo e conclusão para a versão final do alvo editorial.
2. Refinar a seção metodológica para explicitar com mais força a ponte entre Ericeira, Peniche e a modelagem abstrata.
3. Enxugar a bibliografia de trabalho, priorizando os arquivos mais fortes de `references/curated`.
4. Selecionar quais figuras e tabelas de `Paper/generated` realmente entram no artigo final.
5. Rodar nova rodada de sensibilidade no script R, caso seja necessário testar cenários adicionais de `P`, `L`, `G`, `C_a` e diferenças de ordem de grandeza entre offshore e surfe.
6. Decidir se o apêndice deve permanecer robusto ou se parte dele deve migrar para o corpo principal do artigo.
7. Revisar a consistência das citações locais e de literatura cinzenta, especialmente nos materiais sobre Peniche, economia do surf e relatórios portugueses.
8. Fazer leitura final do PDF compilado, verificando linguagem, repetição de ideias, tamanho do texto e aderência ao periódico-alvo.

## Estrutura relevante

### Artigo

- [`Paper/main.tex`](/c:/Git/temas/grupo3/Paper/main.tex): arquivo principal do artigo.
- [`Paper/Game theoretic Model.tex`](/c:/Git/temas/grupo3/Paper/Game%20theoretic%20Model.tex): formulação do problema e do jogo.
- [`Paper/appendix.tex`](/c:/Git/temas/grupo3/Paper/appendix.tex): apêndice com contexto suplementar, agenda analítica e extensões.
- [`Paper/references.bib`](/c:/Git/temas/grupo3/Paper/references.bib): bibliografia BibTeX do paper.
- [`Paper/main.pdf`](/c:/Git/temas/grupo3/Paper/main.pdf): PDF compilado mais recente.

### Código

- [`code/peniche_offshore_analysis.R`](/c:/Git/temas/grupo3/code/peniche_offshore_analysis.R): workflow principal de análise exploratória.
- [`code/README.md`](/c:/Git/temas/grupo3/code/README.md): instruções e ligação do código com o artigo.

### Dados úteis para parametrização

- [`Dados Peniche.xlsx`](/c:/Git/temas/grupo3/Dados%20Peniche.xlsx): planilha principal com a aba `Problema de Decisão Abstrato`.
- [`data/peniche_municipal_indicators.pdf`](/c:/Git/temas/grupo3/data/peniche_municipal_indicators.pdf): indicadores municipais de Peniche.
- [`data/peniche_local_surf_economy_neves_2021.pdf`](/c:/Git/temas/grupo3/data/peniche_local_surf_economy_neves_2021.pdf): economia local do surf em Peniche.
- [`data/ericeira_world_surfing_reserve_impact_study_2022.pdf`](/c:/Git/temas/grupo3/data/ericeira_world_surfing_reserve_impact_study_2022.pdf): estudo de impacto da reserva mundial de surf de Ericeira.
- [`data/parameter_notes_maureen_for_model.txt`](/c:/Git/temas/grupo3/data/parameter_notes_maureen_for_model.txt): notas qualitativas para construção de parâmetros.
- [`data/README.md`](/c:/Git/temas/grupo3/data/README.md): racional da seleção dos dados.

### Referências curadas

- [`references/curated`](/c:/Git/temas/grupo3/references/curated): acervo triado de arquivos relevantes para sustentar o artigo.
- [`references/CURATED_REFERENCES.md`](/c:/Git/temas/grupo3/references/CURATED_REFERENCES.md): inventário arquivo a arquivo do que foi mantido e por quê.
- [`references/Dados_Peniche_Problema_de_Decisao_Abstrato.tsv`](/c:/Git/temas/grupo3/references/Dados_Peniche_Problema_de_Decisao_Abstrato.tsv): extração tabular da aba central da planilha.
- [`references/USED_FILES.md`](/c:/Git/temas/grupo3/references/USED_FILES.md): visão resumida dos arquivos ativos no fluxo atual.

### Saídas geradas

- [`Paper/generated`](/c:/Git/temas/grupo3/Paper/generated): saídas do script R, incluindo matrizes, séries e figuras exploratórias.

### Material descartado

- [`vault/curated`](/c:/Git/temas/grupo3/vault/curated): arquivos triados e considerados não relevantes para o recorte atual do artigo.
- [`vault/data_screening`](/c:/Git/temas/grupo3/vault/data_screening): materiais avaliados como fracos para parametrização.
- [`vault/discarded`](/c:/Git/temas/grupo3/vault/discarded): itens antigos, duplicados ou superados.
- [`vault/CURATED_VAULT.md`](/c:/Git/temas/grupo3/vault/CURATED_VAULT.md): justificativa da triagem para o `vault`.
- [`vault/NON_RELEVANT_FILES.md`](/c:/Git/temas/grupo3/vault/NON_RELEVANT_FILES.md): descarte anterior já consolidado.

## Observação

O diretório `vault` guarda material cuja triagem indicou não relevância para o trabalho no recorte atual. Esses arquivos foram preservados apenas para rastreabilidade e eventual reavaliação futura, não como base ativa do artigo.
