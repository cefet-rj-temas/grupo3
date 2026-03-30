# Carregar bibliotecas necessárias
library(dplyr)
library(tibble)

# 1. Definição da Função de Payoffs (Validada por você)
compute_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)         # Payoff do consórcio no conflito
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)       # Payoff do surf no conflito

  matrix_tbl <- tibble(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),
    surf_action = c("Accept", "Fight", "Accept", "Fight"),
    offshore_payoff = c(R, g1, 0, 0),
    surf_payoff = c(I - L, g2, I, I - alpha * Ca)
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
      ),
      is_pareto_max = total_payoff == max(total_payoff)
    )
}

# 2. Bloco de entrada de dados via Console
cat("--- Configuração do Simulador de Negociação ---\n")

# Captura de cada variável
R  <- as.numeric(readline("Digite o Retorno do Consórcio (R): "))
LR <- as.numeric(readline("Digite a Perda de Retorno por atraso (LR): "))
Cs <- as.numeric(readline("Digite o Custo Judicial do Consórcio (Cs): "))
I  <- as.numeric(readline("Digite a Renda Inicial do Surf (I): "))
L  <- as.numeric(readline("Digite a Perda Econômica Local (L): "))
alpha <- as.numeric(readline("Digite o fator alpha (mobilização pré-conflito): "))
Ca <- as.numeric(readline("Digite o Custo Judicial do Surf (Ca): "))
G  <- as.numeric(readline("Digite o Valor da Compensação Proposta (G): "))
P  <- as.numeric(readline("Digite a Probabilidade da Usina vencer na justiça (0 a 1): "))

# 3. Execução do cálculo
resultado <- compute_payoffs(R, LR, Cs, I, L, alpha, Ca, G, P)

# 4. Exibição dos resultados no console
cat("\n--- Matriz de Resultados ---\n")
print(resultado)

# Identificação visual do Equilíbrio de Nash
nash_cenario <- resultado %>% filter(is_nash == TRUE)
cat("\n--- Diagnóstico Estratégico ---\n")
cat("O Equilíbrio de Nash encontrado é:", nash_cenario$offshore_action, "+", nash_cenario$surf_action, "\n")