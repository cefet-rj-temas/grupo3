library(dplyr)
library(tibble)
library(purrr)
library(ggplot2)

# Função de Payoffs
compute_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)
  
  matrix_tbl <- tibble(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),
    surf_action = c("Accept", "Fight", "Accept", "Fight"),
    offshore_payoff = c(R, g1, 0, 0),
    surf_payoff = c(I - L, g2, I, I - alpha * Ca),
    G_scenario = G # Identificador do valor de G para este cenário
  )
  
  matrix_tbl %>%
    mutate(
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
    filter(is_nash == TRUE)
}

# Entrada de dados
cat("--- Configuração da Análise de Sensibilidade (Variação de G) ---\n")
R  <- as.numeric(readline("Digite o Retorno do Consórcio (R): "))
LR <- as.numeric(readline("Digite a Perda de Retorno por atraso (LR): "))
Cs <- as.numeric(readline("Digite o Custo Judicial do Consórcio (Cs): "))
I  <- as.numeric(readline("Digite a Renda Inicial do Surf (I): "))
L  <- as.numeric(readline("Digite a Perda Econômica Local (L): "))
alpha <- as.numeric(readline("Digite o fator alpha: "))
Ca <- as.numeric(readline("Digite o Custo Judicial do Surf (Ca): "))
P  <- as.numeric(readline("Digite a Probabilidade fixa (P) [0 a 1]: "))

# Implementação do RANGE para G
# Testando de 0 até 1.5x o valor da perda L para encontrar o ponto de virada
g_range <- seq(0, L * 1.5, length.out = 20)

cat("\nExecutando análise para G variando de 0 a", max(g_range), "...\n")

mapa_sensibilidade_G <- g_range %>%
  map_df(~ compute_payoffs(R, LR, Cs, I, L, alpha, Ca, .x, P))

# Exibição dos Resultados
cat("\n--- Parecer de Realidade: Sensibilidade de G ---\n")
print(mapa_sensibilidade_G %>% select(G_scenario, offshore_action, surf_action))

# Visualização Gráfica sugerida (Line Chart de Payoffs para o Surf)
p_range_grafico <- seq(0, L * 1.5, length.out = 100)
dados_plot <- tibble(G = p_range_grafico) %>%
  mutate(
    Accept = I - L + G, # O Surf ganha a renda menos a perda mais a compensação
    Fight  = (1 - P) * (I - Ca) + P * (I - L + G - Ca) # Expectativa judicial g2
  )

ggplot(dados_plot, aes(x = G)) +
  geom_line(aes(y = Accept, color = "Acordo (G)"), size = 1) +
  geom_line(aes(y = Fight, color = "Luta (Expectativa)"), linetype = "dashed", size = 1) +
  labs(title = paste("Sensibilidade de G para P =", P),
       x = "Valor da Compensação (G)", y = "Payoff do Surf", color = "Decisão") +
  theme_minimal()

