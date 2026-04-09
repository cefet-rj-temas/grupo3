library(dplyr)
library(tibble)
library(purrr)
library(ggplot2)

# ============================================================================
# 1. MOTOR DO JOGO: Cálculo da Matriz de Payoffs e Equilíbrio de Nash
# ============================================================================
compute_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  
  # Cenários de Conflito (Aposta Judicial)
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)   # Expectativa do Consórcio ao lutar
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca) # Expectativa do Surf ao lutar
  
  # Construção da Matriz 2x2 do Jogo
  matrix_tbl <- tibble(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),
    surf_action     = c("Accept", "Fight", "Accept", "Fight"),
    offshore_payoff = c(R, g1, 0, 0),
    surf_payoff     = c(I - L, g2, I, I - alpha * Ca),
    G_scenario      = G # Rastreia qual valor de compensação gerou este cenário
  )
  
  # Avaliação de Racionalidade e Equilíbrio
  matrix_tbl %>%
    mutate(
      # O Consórcio maximiza seu ganho dado a escolha do Surf?
      better_for_offshore = c(
        offshore_payoff[1] >= offshore_payoff[3], # Se Surf aceita: Implementar >= Desistir?
        offshore_payoff[2] >= offshore_payoff[4], # Se Surf luta: Implementar >= Desistir?
        offshore_payoff[3] >= offshore_payoff[1], # Inverso
        offshore_payoff[4] >= offshore_payoff[2]  # Inverso
      ),
      # O Surf maximiza seu ganho dado a escolha do Consórcio?
      better_for_surf = c(
        surf_payoff[1] >= surf_payoff[2], # Se Usina implementa: Aceitar >= Lutar?
        surf_payoff[2] >= surf_payoff[1], # Inverso
        surf_payoff[3] >= surf_payoff[4], # Se Usina desiste: Aceitar >= Lutar?
        surf_payoff[4] >= surf_payoff[3]  # Inverso
      ),
      # Nash ocorre quando NENHUM jogador tem incentivo para mudar de ideia sozinho
      is_nash = better_for_offshore & better_for_surf
    ) %>%
    filter(is_nash == TRUE) # Retorna apenas a estratégia estável
}

# ============================================================================
# 2. ENTRADA DE DADOS E PARÂMETROS DO MODELO
# ============================================================================
cat("--- Configuração da Análise de Sensibilidade da Compensação (G) ---\n")
R     <- as.numeric(readline("Digite o Retorno do Consórcio (R): "))
LR    <- as.numeric(readline("Digite a Perda de Retorno por atraso (LR): "))
Cs    <- as.numeric(readline("Digite o Custo Judicial do Consórcio (Cs): "))
I     <- as.numeric(readline("Digite a Renda Inicial do Surf (I): "))
L     <- as.numeric(readline("Digite a Perda Econômica Local (L): "))
alpha <- as.numeric(readline("Digite o fator alpha (Mobilização pré-conflito): "))
Ca    <- as.numeric(readline("Digite o Custo Judicial do Surf (Ca): "))
P     <- as.numeric(readline("Digite a Probabilidade fixa da Usina vencer (P) [0 a 1]: "))

# ============================================================================
# 3. EXECUÇÃO DA SENSIBILIDADE EM LOTE (GRID SEARCH)
# ============================================================================
# Testamos ofertas de 0 até 50% acima do prejuízo local (L * 1.5)
g_range <- seq(0, L * 1.5, length.out = 20)

cat("\nExecutando análise para G variando de 0 a", max(g_range), "...\n")

# Mapeia a função para cada valor de G e empilha os resultados
mapa_sensibilidade_G <- g_range %>%
  map_df(~ compute_payoffs(R, LR, Cs, I, L, alpha, Ca, .x, P))

cat("\n--- Parecer de Realidade: Sensibilidade de G ---\n")
print(mapa_sensibilidade_G %>% select(G_scenario, offshore_action, surf_action))

# ============================================================================
# 4. PREPARAÇÃO DE DADOS PARA O GRÁFICO INVESTIGATIVO
# ============================================================================
# Usamos 100 pontos para garantir que as linhas do gráfico fiquem suaves
p_range_grafico <- seq(0, L * 1.5, length.out = 100)

dados_plot <- tibble(G = p_range_grafico) %>%
  mutate(
    Accept = I - L,                                   # Payoff se render ao Acordo
    Fight  = (1 - P) * (I - Ca) + P * (I - L + G - Ca) # Payoff esperado na Luta (g2)
  )

# Cálculo algébrico exato onde a decisão muda (Accept == Fight)
G_point <- (Ca - L * (1 - P)) / P

# ============================================================================
# 5. RENDERIZAÇÃO DO GRÁFICO DE FRONTEIRA DE RACIONALIDADE
# ============================================================================
grafico_base <- ggplot(dados_plot, aes(x = G)) +
  geom_line(aes(y = Accept, color = "Acordo", linetype = "Acordo"), linewidth = 1) +
  geom_line(aes(y = Fight, color = "Luta", linetype = "Luta"), linewidth = 1) +
  
  scale_color_manual(values = c("Acordo" = "black", "Luta" = "gray40")) +
  scale_linetype_manual(values = c("Acordo" = "dashed", "Luta" = "solid")) +
  
  labs(
    title = paste("Sensibilidade da Oferta de Compensação (G) para P =", P),
    subtitle = "Cruzamento de Payoffs para os Stakeholders (Surf)",
    x = "Valor da Oferta de Compensação (G)", 
    y = "Payoff Esperado do Surf", 
    color = "Decisão Racional",
    linetype = "Decisão Racional" 
  ) +
  
  theme_bw(base_size = 12, base_family = "serif") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 11, color = "gray30"),
    legend.position = "bottom", 
    legend.title = element_text(face = "bold"),
    legend.background = element_rect(color = "black", linewidth = 0.3),
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_line(color = "gray90") 
  )

# Lógica de anotação do Ponto de Mudança
if (!is.na(G_point) && G_point >= 0) {
  grafico_final <- grafico_base +
    geom_point(aes(x = G_point, y = I - L), size = 3, shape = 21, fill = "white", color = "black", stroke = 1) +
    annotate("text", x = G_point + (max(g_range) * 0.02), y = I - L, 
             label = paste("Preço da Paz: G =", round(G_point, 2)), 
             hjust = 0, vjust = -1.5, family = "serif", size = 4)
} else {
  grafico_final <- grafico_base
  cat("\n[Aviso] O Ponto de Mudança (G) é negativo. O Acordo domina a Luta em todo o cenário realista.\n")
}

print(grafico_final)
