library(dplyr)
library(tibble)
library(purrr)
library(ggplot2) # Adicionada para geração dos gráficos
library(tidyr)   # Adicionada para organizar os dados do gráfico

# 1. Modificação na Função: Agora ela retorna todos os cenários para o gráfico
compute_all_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)
  
  # Retornamos uma estrutura simplificada focada nos payoffs de interesse
  tibble(
    P_scenario = P,
    offshore_accept = R,      # Valor fixo de Implement/Accept
    offshore_fight = g1,      # Valor g1 (conflito)
    surf_accept = I - L,      # Valor fixo de Implement/Accept
    surf_fight = g2           # Valor g2 (conflito)
  )
}

# --- Entrada de dados (Mantida igual ao seu original) ---
cat("--- Configuração dos Payoffs Comparativos ---\n")
R  <- as.numeric(readline("Retorno (R): "))
LR <- as.numeric(readline("Perda por atraso (LR): "))
Cs <- as.numeric(readline("Custo Judicial Usina (Cs): "))
I  <- as.numeric(readline("Renda Inicial Surf (I): "))
L  <- as.numeric(readline("Perda Econômica Local (L): "))
alpha <- as.numeric(readline("Fator alpha: "))
Ca <- as.numeric(readline("Custo Judicial Surf (Ca): "))
G  <- as.numeric(readline("Valor da Compensação (G): "))

# 2. Gerando os dados para o gráfico (Range mais fino para linhas suaves)
p_range_fine <- seq(0, 1, by = 0.01)
dados_grafico <- p_range_fine %>%
  map_df(~ compute_all_payoffs(R, LR, Cs, I, L, alpha, Ca, G, .x))

# 3. Gerando o Gráfico para o Player: SURF (Stakeholders)
grafico_surf <- ggplot(dados_grafico, aes(x = P_scenario)) +
  geom_line(aes(y = surf_accept, color = "Acordo (I - L)"), size = 1.2) +
  geom_line(aes(y = surf_fight, color = "Conflito (g2)"), size = 1.2, linetype = "dashed") +
  scale_color_manual(values = c("Acordo (I - L)" = "blue", "Conflito (g2)" = "red")) +
  labs(
    title = "Fronteira de Racionalidade: Stakeholders (Surf)",
    subtitle = paste("Compensação G =", G),
    x = "Probabilidade da Usina Vencer (P)",
    y = "Payoff (€)",
    color = "Cenário"
  ) +
  theme_classic()

# Exibir o gráfico
print(grafico_surf)

# 4. (Opcional) Gráfico para o Player: OFFSHORE (Consórcio)
grafico_offshore <- ggplot(dados_grafico, aes(x = P_scenario)) +
  geom_line(aes(y = offshore_accept, color = "Acordo (R)"), size = 1.2) +
  geom_line(aes(y = offshore_fight, color = "Conflito (g1)"), size = 1.2, linetype = "dashed") +
  scale_color_manual(values = c("Acordo (R)" = "blue", "Conflito (g1)" = "red")) +
  labs(
    title = "Fronteira de Racionalidade: Consórcio Offshore",
    x = "Probabilidade da Usina Vencer (P)",
    y = "Payoff (€)",
    color = "Cenário"
  ) +
  theme_classic()

print(grafico_offshore)

