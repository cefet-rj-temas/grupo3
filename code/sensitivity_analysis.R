library(dplyr)
library(tibble)
library(purrr) #  Biblioteca para facilitar a repetição dos cálculos

# Função de Payoffs
compute_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)                             # Valor após lutar do consórcio
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)                           # Valor após lutar do surf

  
  # A tabela abaixo representa todos os cenários possíveis entre dois jogadores:
  # (offshore vs surf), considerando suas decisões estratégicas.
  #
  # São avaliados os payoffs (ganhos/perdas) para cada combinação de ações:
  # - Offshore: Implementar ou Retirar (Implement / Withdraw)
  # - Surf: Aceitar ou Lutar (Accept / Fight)
  #
  # Estrutura dos cenários:
  #
  # 1) Implement / Accept  -> Offshore: R      | Surf: I - L
  # 2) Implement / Fight   -> Offshore: g1     | Surf: g2
  # 3) Withdraw / Accept   -> Offshore: 0      | Surf: I
  # 4) Withdraw / Fight    -> Offshore: 0      | Surf: I - alpha * Ca
  #
  # O valor P representa a probabilidade associada ao cenário analisado,
  # sendo replicado para todas as combinações.

  matrix_tbl <- tibble(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),  # Coluna offshore_action e suas linhas
    surf_action = c("Accept", "Fight", "Accept", "Fight"),                  # Coluna surf_action e suas linhas
    offshore_payoff = c(R, g1, 0, 0),                                       # Coluna offshore_payoff e suas linhas
    surf_payoff = c(I - L, g2, I, I - alpha * Ca),                          # Coluna surf_payoff e suas linhas
    P_scenario = P # valor de P deste cenário
  )

  matrix_tbl %>%
    # Mutate está adicionando novas colonuas à tabela
    mutate(
      total_payoff = offshore_payoff + surf_payoff,
      #Compara as decisões fixando a ação do surf
      better_for_offshore = c(
        offshore_payoff[1] >= offshore_payoff[3],                           # Implement vs Withdraw (quando surf = Accept)
        offshore_payoff[2] >= offshore_payoff[4],                           # Implement vs Withdraw (quando surf = Fight)
        offshore_payoff[3] >= offshore_payoff[1],                           # Withdraw vs Implement (surf = Accept)
        offshore_payoff[4] >= offshore_payoff[2]                            # Withdraw vs Implement (surf = Fight)
      ),
      #Compara as decisões fixando a ação do consórcio
      better_for_surf = c(
        surf_payoff[1] >= surf_payoff[2],                                   # Accept vs Fight (offshore = Implement)
        surf_payoff[2] >= surf_payoff[1],                                   # Fight vs Accept
        surf_payoff[3] >= surf_payoff[4],                                   # Accept vs Fight (Withdraw)
        surf_payoff[4] >= surf_payoff[3]                                    # Fight vs Accept
      ),
      # Um cenário é equilíbrio de Nash se ambos estão fazendo a melhor escolha dado o outro.
      is_nash = c(
        better_for_offshore[1] && better_for_surf[1],
        better_for_offshore[2] && better_for_surf[2],
        better_for_offshore[3] && better_for_surf[3],
        better_for_offshore[4] && better_for_surf[4]
      )
    ) %>%
    filter(is_nash == TRUE) # Para a análise de sensibilidade, só nos interessa o equilíbrio nash
}

# Entrada de dados (Variáveis fixas)
cat("--- Configuração da Análise de Sensibilidade (Variação de P) ---\n")
R  <- as.numeric(readline("Digite o Retorno do Consórcio (R): "))
LR <- as.numeric(readline("Digite a Perda de Retorno por atraso (LR): "))
Cs <- as.numeric(readline("Digite o Custo Judicial do Consórcio (Cs): "))
I  <- as.numeric(readline("Digite a Renda Inicial do Surf (I): "))
L  <- as.numeric(readline("Digite a Perda Econômica Local (L): "))
alpha <- as.numeric(readline("Digite o fator alpha: "))
Ca <- as.numeric(readline("Digite o Custo Judicial do Surf (Ca): "))
G  <- as.numeric(readline("Digite o Valor da Compensação (G): "))

# Implementação do RANGE para P
# Sequência de 0 a 1, aumentando de 0.1 em 0.1
p_range <- seq(0, 1, by = 0.1)

cat("\nExecutando análise para P variando de 0 a 1...\n")

# Execução em lote usando map_df (purrr)
# Isso aplica a função compute_payoffs para cada valor dentro de p_range
mapa_sensibilidade <- p_range %>%
  map_df(~ compute_payoffs(R, LR, Cs, I, L, alpha, Ca, G, .x))

# Exibição dos Resultados de Sensibilidade
cat("\n--- Parecer de Realidade: Sensibilidade de P ---\n")
print(mapa_sensibilidade %>% select(P_scenario, offshore_action, surf_action))

cat("\nNota: Observe em qual valor de P o equilíbrio muda de 'Accept' para 'Fight'.\n")