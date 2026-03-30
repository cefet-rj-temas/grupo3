library(dplyr)
library(tibble)
library(purrr) # Nova biblioteca para facilitar a repetição dos cálculos

# 1. Função de Payoffs
compute_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)

  matrix_tbl <- tibble(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),
    surf_action = c("Accept", "Fight", "Accept", "Fight"),
    offshore_payoff = c(R, g1, 0, 0),
    surf_payoff = c(I - L, g2, I, I - alpha * Ca),
    P_scenario = P # Guardamos o valor de P deste cenário
  )

  matrix_tbl %>%
    mutate(
      total_payoff = offshore_payoff + surf_payoff,
      better_for_offshore = c(
        offshore_payoff[1] >= offshore_payoff[3],
        offshore_payoff[2] >= offshore_payoff[4],
        offshore_payoff[3] >= offshore_payoff[1],
        offshore_payoff[4] >= offshore_payoff[2]
      ),
      better_for_surf = c(
        surf_payoff[1] >= surf_payoff[2],
        surf_payoff[2] >= surf_payoff[1],
        surf_payoff[3] >= surf_payoff[4],
        surf_payoff[4] >= surf_payoff[3]
      ),
      is_nash = c(
        better_for_offshore[1] && better_for_surf[1],
        better_for_offshore[2] && better_for_surf[2],
        better_for_offshore[3] && better_for_surf[3],
        better_for_offshore[4] && better_for_surf[4]
      )
    ) %>%
    filter(is_nash == TRUE) # Para a análise de sensibilidade, só nos interessa o equilíbrio
}

# 2. Entrada de dados (Variáveis fixas)
cat("--- Configuração da Análise de Sensibilidade (Variação de P) ---\n")
R  <- as.numeric(readline("Digite o Retorno do Consórcio (R): "))
LR <- as.numeric(readline("Digite a Perda de Retorno por atraso (LR): "))
Cs <- as.numeric(readline("Digite o Custo Judicial do Consórcio (Cs): "))
I  <- as.numeric(readline("Digite a Renda Inicial do Surf (I): "))
L  <- as.numeric(readline("Digite a Perda Econômica Local (L): "))
alpha <- as.numeric(readline("Digite o fator alpha: "))
Ca <- as.numeric(readline("Digite o Custo Judicial do Surf (Ca): "))
G  <- as.numeric(readline("Digite o Valor da Compensação (G): "))

# 3. Implementação do RANGE para P
# Criamos uma sequência de 0 a 1, aumentando de 0.1 em 0.1
p_range <- seq(0, 1, by = 0.1)

cat("\nExecutando análise para P variando de 0 a 1...\n")

# 4. Execução em lote usando map_df (purrr)
# Isso aplica a função compute_payoffs para cada valor dentro de p_range
mapa_sensibilidade <- p_range %>%
  map_df(~ compute_payoffs(R, LR, Cs, I, L, alpha, Ca, G, .x))

# 5. Exibição dos Resultados de Sensibilidade
cat("\n--- Parecer de Realidade: Sensibilidade de P ---\n")
print(mapa_sensibilidade %>% select(P_scenario, offshore_action, surf_action))

cat("\nNota: Observe em qual valor de P o equilíbrio muda de 'Accept' para 'Fight'.\n")