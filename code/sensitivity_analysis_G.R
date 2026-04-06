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
# Utliza-se 20 valores igualmente espaçados 
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
    Accept = I - L ,
    Fight  = (1 - P) * (I - Ca) + P * (I - L + G - Ca),
    Fight_plot = ifelse(Fight >= Accept, Fight, NA)
  )

# Cálculo corrigido do Ponto de Mudança
G_point <- (Ca - L * (1 - P)) / P

# 1. Criação do Gráfico Base (apenas linhas, eixos e tema)
grafico_base <- ggplot(dados_plot, aes(x = G)) +
  geom_line(aes(y = Accept, color = "Acordo", linetype = "Acordo"), linewidth = 1) +
  geom_line(aes(y = Fight, color = "Luta", linetype = "Luta"), linewidth = 1) +
  
  scale_color_manual(values = c("Acordo" = "black", "Luta" = "gray40")) +
  scale_linetype_manual(values = c("Acordo" = "dashed", "Luta" = "solid")) +
  
  labs(
    title = paste("Análise de Sensibilidade da Compensação (G) para P =", P),
    x = "Compensação (G)", 
    y = "Payoff do Surf", 
    color = "Decisão",
    linetype = "Decisão" 
  ) +
  
  theme_bw(base_size = 12, base_family = "serif") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    legend.position = "bottom", 
    legend.title = element_text(face = "bold"),
    legend.background = element_rect(color = "black", linewidth = 0.3),
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_line(color = "gray90") 
  )

# 2. Adição Condicional do Ponto de Mudança
# Só adiciona o ponto e a anotação se G_point for positivo ou zero
if (!is.na(G_point) && G_point >= 0) {
  grafico_final <- grafico_base +
    geom_point(aes(x = G_point, y = I - L), size = 3, shape = 21, fill = "white", color = "black", stroke = 1) +
    annotate("text", x = G_point + (max(g_range) * 0.02), y = I - L, 
             label = "Ponto de mudança", hjust = 0, vjust = -1, family = "serif", size = 4)
} else {
  # Se G_point for negativo, mantém apenas o gráfico base
  grafico_final <- grafico_base
  cat("\n[Nota] O Ponto de Mudança é negativo (G =", round(G_point, 2), "). Uma estratégia domina a outra.\n")
}

# 3. Exibir o gráfico
print(grafico_final)

