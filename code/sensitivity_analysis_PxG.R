library(dplyr)
library(tibble)
library(purrr)
library(ggplot2)
library(tidyr)

# ============================================================================
# 1. MOTOR DE DECISÃO: Diagnóstico de Equilíbrio de Nash
# ============================================================================
get_nash_equilibrium <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  
  # Expectativa de ganhos no cenário de litígio judicial
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)
  
  # Estrutura da Matriz 2x2 do Jogo
  matrix_tbl <- tibble(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),
    surf_action     = c("Accept", "Fight", "Accept", "Fight"),
    offshore_payoff = c(R, g1, 0, 0),
    surf_payoff     = c(I - L, g2, I, I - alpha * Ca)
  )
  
  # Varredura de Racionalidade: Busca pelas Melhores Respostas
  nash_cenario <- matrix_tbl %>%
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
      is_nash = better_for_offshore & better_for_surf
    ) %>%
    filter(is_nash == TRUE)
  
  # Tratamento para ausência de Equilíbrio em Estratégias Puras (Instabilidade)
  if (nrow(nash_cenario) == 0) {
    return("Sem Equilíbrio Puro") 
  } else {
    nash_cenario <- slice(nash_cenario, 1) # Filtra empate técnico
    return(paste(nash_cenario$offshore_action, nash_cenario$surf_action, sep = " / "))
  }
}

# ============================================================================
# 2. CALIBRAÇÃO DO MODELO COM DADOS REAIS
# ============================================================================
cat("--- Configuração da Matriz Bidimensional (P vs G) ---\n")
R     <- as.numeric(readline("Retorno da Usina (R): "))
LR    <- as.numeric(readline("Perda por atraso no projeto (LR): "))
Cs    <- as.numeric(readline("Custo Judicial do Consórcio (Cs): "))
I     <- as.numeric(readline("Renda Inicial Local do Surf (I): "))
L     <- as.numeric(readline("Perda Econômica Local Esperada (L): "))
alpha <- as.numeric(readline("Fator alpha (Custo de mobilização): "))
Ca    <- as.numeric(readline("Custo Judicial do Surf (Ca): "))

# ============================================================================
# 3. CRIAÇÃO DA MALHA DE CENÁRIOS (MULTIVERSO)
# ============================================================================
p_grid <- seq(0, 1, length.out = 100)
g_grid <- seq(0, L * 1.5, length.out = 100)

grade_cenarios <- expand_grid(P = p_grid, G = g_grid)
cat("\nSimulando", nrow(grade_cenarios), "cenários de Teoria dos Jogos...\n")

# ============================================================================
# 4. SIMULAÇÃO EM MASSA
# ============================================================================
dados_heatmap <- grade_cenarios %>%
  mutate(
    Equilibrio = pmap_chr(list(P, G), ~ get_nash_equilibrium(R, LR, Cs, I, L, alpha, Ca, ..2, ..1))
  )

# ============================================================================
# 5. VISUALIZAÇÃO: O MAPA DE CALOR (HEATMAP)
# ============================================================================
grafico_calor <- ggplot(dados_heatmap, aes(x = G, y = P, fill = Equilibrio)) +
  geom_tile() +
  
  # Paleta de cores semântica
  scale_fill_manual(values = c(
    "Implement / Accept"  = "#4CAF50",  # Verde (Acordo)
    "Implement / Fight"   = "#F44336",  # Vermelho (Conflito)
    "Withdraw / Accept"   = "#9E9E9E",  # Cinza (Desistência)
    "Withdraw / Fight"    = "#607D8B",  # Cinza escuro
    "Sem Equilíbrio Puro" = "#FFC107"   # Amarelo (Caos/Instabilidade)
  )) +
  
  # Faz as cores encostarem exatamente nas bordas dos eixos (padrão de artigo)
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  
  labs(
    title = "Mapa de Sensibilidade: Segurança Jurídica vs. Oferta de Compensação",
    subtitle = "Zonas de Equilíbrio de Nash no Conflito Offshore vs. Stakeholders (Surf)",
    x = "Valor da Compensação Financeira Oferecida (G)",
    y = "Probabilidade da Usina Vencer no Tribunal (P)",
    fill = "Desfecho Racional:"
  ) +
  
  # Aplicação da Identidade Visual do Gráfico de Linhas
  theme_bw(base_size = 12, base_family = "serif") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 11, color = "gray30"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    legend.background = element_rect(color = "black", linewidth = 0.3), # Caixa ao redor da legenda
    panel.grid = element_blank(), # Malha interna limpa para não fatiar o heatmap
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1) # Borda forte ao redor do gráfico
  )

# Renderiza o gráfico final
print(grafico_calor)

