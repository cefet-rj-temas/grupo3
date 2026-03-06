# https://github.com/yukiyanai/rgamer

devtools::install_github("yukiyanai/rgamer")

library(rgamer)

game1 <- normal_form(
  players = c("Kamijo", "Yanai"),
  s1 = c("Stays silent", "Betrays"), 
  s2 = c("Stays silent", "Betrays"), 
  payoffs1 = c(-1,  0, -3, -2), 
  payoffs2 = c(-1, -3,  0, -2))


s_game1 <- solve_nfg(game1, show_table = FALSE)

s_game1$table

s_game1$br_plot


game1b <- normal_form(
  players = c("Kamijo", "Yanai"),
  s1 = c("Stays silent", "Betrays"), 
  s2 = c("Stays silent", "Betrays"), 
  cells = list(c(-1, -1), c(-3,  0),
               c( 0, -3), c(-2, -2)),
  byrow = TRUE)





game1 <- normal_form(players = c("Hotel", "Fishers"),
  s1 = c("Co-operate", "Not co-operate"), 
  s2 = c("Co-operate", "Not co-operate"),
  payoffs1 = c(15,  18,  9, 12), 
  payoffs2 = c(5, 2, 7, 3))

#_game1 <- solve_nfg(game1, mixed = TRUE, show_table = FALSE)


s_game1 <- solve_nfg(game1, show_table = TRUE)




game1 <- normal_form(players = c("Hotel", "Fishers"),
                     s1 = c("Co-operate", "Not co-operate"), 
                     s2 = c("Co-operate", "Not co-operate"),
                     payoffs1 = c(30,  36,  18, 24), 
                     payoffs2 = c(10, 4, 14, 6))

#_game1 <- solve_nfg(game1, mixed = TRUE, show_table = FALSE)


s_game1 <- solve_nfg(game1, show_table = TRUE)


game1 <- normal_form(players = c("Hotel", "Fishers"),
                     s1 = c("Co-operate", "Not co-operate"), 
                     s2 = c("Co-operate", "Not co-operate"),
                     payoffs1 = c(30,  16,  18, 16), 
                     payoffs2 = c(10, 4, 4, 2))

#_game1 <- solve_nfg(game1, mixed = TRUE, show_table = FALSE)


s_game1 <- solve_nfg(game1, show_table = TRUE)
