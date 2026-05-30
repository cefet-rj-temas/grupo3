#!/usr/bin/env Rscript

# Reproducible workflow for the integrated offshore-wind versus surf-tourism
# article. The script reads the Peniche workbook, reconstructs the abstract
# decision model, computes equilibrium diagnostics, and exports exploratory
# tables and figures that can be cited in the paper.

required_packages <- c("readxl", "dplyr", "tidyr", "purrr", "ggplot2", "stringr")

missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop(
    "Missing R packages: ",
    paste(missing_packages, collapse = ", "),
    ". Install them before running this script."
  )
}

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(ggplot2)
  library(stringr)
})

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || is.na(x)) y else x
}

script_path <- commandArgs(trailingOnly = FALSE) %>%
  stringr::str_subset("^--file=") %>%
  stringr::str_remove("^--file=") %>%
  .[1] %||% "."

root_dir <- normalizePath(file.path(dirname(script_path), ".."), winslash = "/", mustWork = TRUE)
data_file <- file.path(root_dir, "Dados Peniche.xlsx")
output_dir <- file.path(root_dir, "Paper", "generated")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

read_sheet_raw <- function(path, sheet) {
  read_excel(path, sheet = sheet, col_names = FALSE)
}

get_symbol_value <- function(tbl, symbol) {
  row <- tbl %>%
    filter(.data[["...2"]] == symbol) %>%
    slice(1)

  if (nrow(row) == 0) {
    stop("Symbol not found in worksheet: ", symbol)
  }

    row$...3[[1]]
}

build_parameters <- function(problem_sheet) {
  tibble(
    symbol = c("R", "LR", "Cs", "I", "L", "alpha", "Ca", "G", "P"),
    value = c(
      get_symbol_value(problem_sheet, "R"),
      get_symbol_value(problem_sheet, "LR"),
      get_symbol_value(problem_sheet, "Cs"),
      get_symbol_value(problem_sheet, "I"),
      get_symbol_value(problem_sheet, "L"),
      get_symbol_value(problem_sheet, "alpha"),
      get_symbol_value(problem_sheet, "Ca"),
      get_symbol_value(problem_sheet, "G"),
      get_symbol_value(problem_sheet, "P")
    )
  )
}

compute_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)

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

build_peniche_series <- function(data_sheet) {
  years <- suppressWarnings(as.integer(unlist(data_sheet[3, 2:10])))

  normalize_label <- function(x) {
    x %>%
      as.character() %>%
      stringr::str_replace_all("\\s+", " ") %>%
      stringr::str_trim()
  }

  extract_row <- function(label) {
    normalized_label <- normalize_label(label)
    row <- data_sheet %>%
      mutate(label_norm = normalize_label(.data[["...1"]])) %>%
      filter(label_norm == normalized_label) %>%
      slice(1) %>%
      select(2:10) %>%
      unlist(use.names = FALSE)

    tibble(year = years, value = as.numeric(row))
  }

  bind_rows(
    extract_row("Capacidade de aojamento nos estabelecimentos hoteleiros") %>% mutate(indicator = "Accommodation capacity"),
    extract_row("Nights (No.) in tourist accommodation establishments by Geographic localization (NUTS -\n2013) and Type (tourist accommodation establishment)") %>% mutate(indicator = "Overnight stays"),
    extract_row("Guests (No.) in tourist accommodation establishments by Geographic localization (NUTS -\n2013) and Type (tourist accommodation establishment)") %>% mutate(indicator = "Guests"),
    extract_row("Total incomes (€) in tourist accommodation establishments by Geographic localization and\nType (tourist accommodation establishment)") %>% mutate(indicator = "Tourism income")
  ) %>%
    filter(!is.na(year), !is.na(value))
}

compute_sensitivity <- function(params) {
  expand_grid(
    P = seq(0.1, 0.9, by = 0.1),
    G = seq(0, 8, by = 1),
    Ca = seq(0, 6, by = 1),
    L = seq(1, 6, by = 1)
  ) %>%
    mutate(
      R = params[["R"]],
      LR = params[["LR"]],
      Cs = params[["Cs"]],
      I = params[["I"]],
      alpha = params[["alpha"]]
    ) %>%
    pmap_dfr(function(P, G, Ca, L, R, LR, Cs, I, alpha) {
      payoffs <- compute_payoffs(R, LR, Cs, I, L, alpha, Ca, G, P)
      implement_fight <- payoffs %>%
        filter(offshore_action == "Implement", surf_action == "Fight")
      implement_accept <- payoffs %>%
        filter(offshore_action == "Implement", surf_action == "Accept")

      tibble(
        P = P,
        G = G,
        Ca = Ca,
        L = L,
        offshore_conflict_payoff = implement_fight$offshore_payoff,
        surf_conflict_payoff = implement_fight$surf_payoff,
        surf_accept_payoff = implement_accept$surf_payoff,
        fight_minus_accept = implement_fight$surf_payoff - implement_accept$surf_payoff,
        offshore_implements = implement_fight$offshore_payoff > 0,
        surf_prefers_fight = implement_fight$surf_payoff >= implement_accept$surf_payoff
      )
    })
}

write_outputs <- function(parameters_tbl, payoff_tbl, peniche_series, sensitivity_tbl) {
  write.csv(parameters_tbl, file.path(output_dir, "model_parameters.csv"), row.names = FALSE)
  write.csv(payoff_tbl, file.path(output_dir, "baseline_payoff_matrix.csv"), row.names = FALSE)
  write.csv(peniche_series, file.path(output_dir, "peniche_tourism_series.csv"), row.names = FALSE)
  write.csv(sensitivity_tbl, file.path(output_dir, "sensitivity_grid.csv"), row.names = FALSE)

  summary_tbl <- sensitivity_tbl %>%
    group_by(P, G) %>%
    summarise(
      share_surf_prefers_fight = mean(surf_prefers_fight),
      share_offshore_implements = mean(offshore_implements),
      .groups = "drop"
    )

  write.csv(summary_tbl, file.path(output_dir, "sensitivity_summary.csv"), row.names = FALSE)

  tourism_plot <- peniche_series %>%
    filter(indicator %in% c("Overnight stays", "Guests", "Tourism income")) %>%
    ggplot(aes(x = year, y = value, color = indicator)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    scale_x_continuous(breaks = sort(unique(peniche_series$year))) +
    labs(
      title = "Peniche tourism indicators used in the article",
      x = NULL,
      y = "Observed value",
      color = NULL
    ) +
    theme_minimal(base_size = 11)

  ggsave(
    filename = file.path(output_dir, "peniche_tourism_indicators.png"),
    plot = tourism_plot,
    width = 9,
    height = 5,
    dpi = 300
  )

  sensitivity_plot <- summary_tbl %>%
    ggplot(aes(x = G, y = P, fill = share_surf_prefers_fight)) +
    geom_tile() +
    scale_fill_gradient(low = "#e9f2f9", high = "#0b4f6c") +
    labs(
      title = "Share of scenarios in which surf-tourism prefers fighting",
      x = "Compensation (G)",
      y = "Probability offshore prevails (P)",
      fill = "Share"
    ) +
    theme_minimal(base_size = 11)

  ggsave(
    filename = file.path(output_dir, "fight_preference_heatmap.png"),
    plot = sensitivity_plot,
    width = 8,
    height = 5,
    dpi = 300
  )
}

problem_sheet <- read_sheet_raw(data_file, "Problema de Decisão Abstrato")
data_sheet <- read_sheet_raw(data_file, "Dados Peniche")

parameters_tbl <- build_parameters(problem_sheet)
params <- stats::setNames(parameters_tbl$value, parameters_tbl$symbol)

baseline_payoff_tbl <- compute_payoffs(
  R = params[["R"]],
  LR = params[["LR"]],
  Cs = params[["Cs"]],
  I = params[["I"]],
  L = params[["L"]],
  alpha = params[["alpha"]],
  Ca = params[["Ca"]],
  G = params[["G"]],
  P = params[["P"]]
)

peniche_series_tbl <- build_peniche_series(data_sheet)
sensitivity_tbl <- compute_sensitivity(params)

write_outputs(parameters_tbl, baseline_payoff_tbl, peniche_series_tbl, sensitivity_tbl)

message("Outputs written to: ", output_dir)
