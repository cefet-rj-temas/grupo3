simular_peniche <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  # Entradas:
  # R: retorno esperado do projeto offshore
  # LR: perdas no projeto offshore se perder
  # Cs: custo de lutar (surfista)
  # I: renda atual do turismo/surfe
  # L: perda no turismo causada pela offshore
  # alpha: fator de redução de custo do opositor
  # Ca: custo de ação do opositor
  # G: compensação paga ao surfe
  # P: probabilidade de a offshore ganhar o processo
  
  # -------------------------
  # Variáveis calculadas
  # -------------------------
  
  G_negativo <- -G # D11: -G
  
  prob_opositor_ganha <- 1 - P # D12: 1 - P
  
  G1V <- R - L -Cs - G # D13: Ganhos da Offshore se ganhar sem oposição
  G1D <- -Cs # D14: Ganhos da Offshore se perder sem oposição
  
  G1VP <- P * G1V # D15: P * (R - G)
  G1DP <- (1 - P) * G1D # D16: (1 - P) * (-LR - G)
  
  G1 <- G1VP + G1DP # D17: Esperança Offshore sem oposição
  
  G2V <- I - Ca # D18: Ganhos se Offshore ganha com oposição
  G2D <- I - L + G - Ca # D19: Ganhos se perde com oposição
  C2 <- alpha * Ca # D20: Custo de lutar para Offshore
  
  G2VP <- (1 - P) * G2V # D21: P * R
  G2DP <- P * G2D # D22: (1 - P) * (-LR)
  
  G2 <- G2VP + G2DP - C2 # D23: Esperança Offshore com oposição
  
  C1OffshoreImplementa <- R
  C1SurfAceita  <- I - L
  C2OffshoreImplementa  <- G1
  C2SurfLuta  <- G2
  C3OffshoreDesiste  <- 0
  C3SurfAceita <- I
  C4OffshoreDesiste  <- 0
  C4SurfLuta <- I - Ca*alpha
  
  P1 <- C1OffshoreImplementa + C1SurfAceita
  P2 <- C2OffshoreImplementa + C2SurfLuta
  P3 <- C3OffshoreDesiste + C3OffshoreDesiste
  P4 <- C4OffshoreDesiste + C4SurfLuta
  
  N1 <- C1OffshoreImplementa >= C3OffshoreDesiste && C2OffshoreImplementa >= C4OffshoreDesiste
  N2 <- C1SurfAceita >= C2SurfLuta && C3SurfAceita >= C4SurfLuta
  N3 <- C3OffshoreDesiste >= C1OffshoreImplementa && C4OffshoreDesiste >= C2OffshoreImplementa
  N4 <- C2SurfLuta >= C1SurfAceita && C4SurfLuta >= C3SurfAceita

  Ni1 <- N1 && N2 
  Ni2	<- N1 && N4
  Ni3	<- N2 && N3 
  Ni4	<- N3 && N4 
  Ni <- c(Ni1, Ni2, Ni3, Ni4)

  Pareto <- which.max(c(P1, P2, P3, P4))
  
  Nash <- 0
  if (sum(Ni) != 0) {
    Nash <- which.max(Ni)    
  }
  
  
  # -------------------------
  # Retorno como lista
  # -------------------------
  return(list(R = R, LR = LR, Cs = Cs, I = I, L = L, alpha = alpha, Ca = Ca, G = G, P = P,
              G_negativo = G_negativo, # D11
              prob_opositor_ganha = prob_opositor_ganha, # D12
              
              G1V = G1V, G1D = G1D, # D13–D14
              G1VP = G1VP, G1DP = G1DP, # D15–D16
              G1 = G1, # D17
              
              G2V = G2V, G2D = G2D, C2 = C2, # D18–D20
              G2VP = G2VP, G2DP = G2DP, # D21–D22
              G2 = G2, # D23
              
              C1OffshoreImplementa = C1OffshoreImplementa,
              C1SurfAceita  = C1SurfAceita,
              C2OffshoreImplementa  = C2OffshoreImplementa,
              C2SurfLuta  = C2SurfLuta,
              C3OffshoreDesiste  = C3OffshoreDesiste,
              C3SurfAceita  = C3SurfAceita,
              C4OffshoreDesiste  = C4OffshoreDesiste,
              C4SurfLuta  = C4SurfLuta,
              
              Pareto = Pareto,
              Nash = Nash
  ))
}
#R, LR, Cs, I, L, alpha, Ca, G, P
#result <- simular_peniche(100, 11, 10, 50, 20, 0.1, 0.01, 9, 0.6)
result <- simular_peniche(100,10,10,100,40,0.0,0,20,0.4)




