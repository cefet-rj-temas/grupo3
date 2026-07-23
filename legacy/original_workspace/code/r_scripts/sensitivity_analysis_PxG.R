library(dplyr)
library(tibble)
library(purrr)
library(ggplot2)
library(tidyr)

# ============================================================================
# 1. FUNÇÃO PRINCIPAL: DEFINIÇÃO DO JOGO E CÁLCULO DO EQUILÍBRIO DE NASH
# ============================================================================
get_nash_equilibrium <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  
  # Cálculo da utilidade esperada sob incerteza (cenário de litígio judicial)
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)
  
  # Representação do jogo simultâneo na forma normal (Normal-form game)
  matrix_tbl <- tibble(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),
    surf_action     = c("Accept", "Fight", "Accept", "Fight"),
    offshore_payoff = c(R, g1, 0, 0),
    surf_payoff     = c(I - L, g2, I, I - alpha * Ca)
  )
  
  # Avaliação das funções de melhor resposta (Best Response Functions)
  nash_cenario <- matrix_tbl %>%
    mutate(
      # Condição de maximização de utilidade para o Consórcio (Offshore)
      better_for_offshore = c(
        offshore_payoff[1] >= offshore_payoff[3],
        offshore_payoff[2] >= offshore_payoff[4],
        offshore_payoff[3] >= offshore_payoff[1],
        offshore_payoff[4] >= offshore_payoff[2]
      ),
      # Condição de maximização de utilidade para os Stakeholders (Surf)
      better_for_surf = c(
        surf_payoff[1] >= surf_payoff[2],
        surf_payoff[2] >= surf_payoff[1],
        surf_payoff[3] >= surf_payoff[4],
        surf_payoff[4] >= surf_payoff[3]
      ),
      # Interseção das melhores respostas define o Equilíbrio de Nash
      is_nash = better_for_offshore & better_for_surf
    ) %>%
    filter(is_nash == TRUE)
  
  # Verificação de existência de Equilíbrio em Estratégias Puras
  if (nrow(nash_cenario) == 0) {
    return("Ausência de Equilíbrio Puro") 
  } else {
    nash_cenario <- slice(nash_cenario, 1) # Seleciona a primeira ocorrência em caso de multiplicidade
    return(paste(nash_cenario$offshore_action, nash_cenario$surf_action, sep = " / "))
  }
}

# ============================================================================
# 2. DEFINIÇÃO DOS PARÂMETROS EXÓGENOS DO MODELO
# ============================================================================
cat("--- Parâmetros do Modelo Bidimensional (P vs G) ---\n")
R     <- as.numeric(readline("Retorno esperado do Consórcio (R): "))
LR    <- as.numeric(readline("Custo de oportunidade por atraso no projeto (LR): "))
Cs    <- as.numeric(readline("Custos de transação/judiciais do Consórcio (Cs): "))
I     <- as.numeric(readline("Receita econômica base dos Stakeholders (I): "))
L     <- as.numeric(readline("Impacto econômico local estimado (L): "))
alpha <- as.numeric(readline("Coeficiente de custo de mobilização (alpha): "))
Ca    <- as.numeric(readline("Custos de transação/judiciais dos Stakeholders (Ca): "))

# ============================================================================
# 3. GERAÇÃO DO ESPAÇO PARAMÉTRICO PARA ANÁLISE DE SENSIBILIDADE
# ============================================================================
# Discretização do espaço de parâmetros (100 níveis por variável)
p_grid <- seq(0, 1, length.out = 100)
g_grid <- seq(0, L * 1.5, length.out = 100)

# Produto cartesiano dos vetores gerando a matriz de cenários (n = 10.000)
grade_cenarios <- expand_grid(P = p_grid, G = g_grid)
cat("\nComputando", nrow(grade_cenarios), "iterações analíticas...\n")

# ============================================================================
# 4. AVALIAÇÃO COMPUTACIONAL EM LOTE
# ============================================================================
# Aplicação da função de equilíbrio sobre a matriz de espaço paramétrico
dados_heatmap <- grade_cenarios %>%
  mutate(
    Equilibrio = pmap_chr(list(P, G), ~ get_nash_equilibrium(R, LR, Cs, I, L, alpha, Ca, ..2, ..1))
  )

# ============================================================================
# 5. VISUALIZAÇÃO GRÁFICA: MAPA DE CALOR (HEATMAP)
# ============================================================================
grafico_calor <- ggplot(dados_heatmap, aes(x = G, y = P, fill = Equilibrio)) +
  geom_tile() +
  
  # Definição do esquema de cores discreto por categoria de equilíbrio
  scale_fill_manual(values = c(
    "Implement / Accept"          = "#4CAF50",  # Acordo mutuamente benéfico
    "Implement / Fight"           = "#F44336",  # Conflito materializado
    "Withdraw / Accept"           = "#9E9E9E",  # Desistência sem conflito
    "Withdraw / Fight"            = "#607D8B",  # Desistência induzida por pressão
    "Ausência de Equilíbrio Puro" = "#FFC107"   # Instabilidade estratégica
  )) +
  
  # Remoção do espaçamento marginal ("padding") nos eixos cartesianos
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  
  labs(
    title = "Análise de Sensibilidade: Probabilidade (P) vs. Compensação (G)",
    subtitle = "Mapeamento das zonas de Equilíbrio de Nash no conflito Offshore vs. Stakeholders",
    x = "Compensação Financeira Oferecida (G)",
    y = "Probabilidade de Êxito Judicial do Consórcio (P)",
    fill = "Equilíbrio Resultante:"
  ) +
  
  # Configuração padronizada
  theme_bw(base_size = 12, base_family = "serif") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 11, color = "gray30"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    legend.background = element_rect(color = "black", linewidth = 0.3), 
    panel.grid = element_blank(), 
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1) 
  )

# Impressão do objeto gráfico
print(grafico_calor)
