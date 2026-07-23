#!/usr/bin/env Rscript

# Reproducible workflow for the offshore-wind versus surf-tourism artifact.
# It implements the same equilibrium-classification rule used in the original
# Jupyter notebook and regenerates the figures used in the manuscript.

args <- commandArgs(trailingOnly = FALSE)
script_arg <- args[grepl("^--file=", args)]
script_path <- if (length(script_arg) > 0) sub("^--file=", "", script_arg[1]) else "."
project_root <- normalizePath(file.path(dirname(script_path), "..", ".."), winslash = "/", mustWork = TRUE)
output_dir <- file.path(project_root, "simulation", "outputs")
figure_dir <- file.path(output_dir, "article_figures")
trace_dir <- file.path(output_dir, "traceability")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(trace_dir, recursive = TRUE, showWarnings = FALSE)

color_map <- c(
  "Implement / Accept" = "#4CAF50",
  "Implement / Fight" = "#F44336",
  "Withdraw / Accept" = "#9E9E9E",
  "Withdraw / Fight" = "#607D8B",
  "Absence of Pure Equilibrium" = "#FFC107"
)

equilibrium_levels <- names(color_map)

build_parameters <- function() {
  data.frame(
    symbol = c("R", "LR", "Cs", "I", "L", "alpha", "Ca", "G", "P"),
    value = c(100, 20, 2, 22, 4.4, 0.1, 3, 4.4, 0.5)
  )
}

as_params <- function(parameters_tbl) {
  values <- parameters_tbl$value
  names(values) <- parameters_tbl$symbol
  values
}

equilibrium_class <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)

  n_ia <- (R >= 0) & ((I - L) >= g2)
  n_if <- (g1 >= 0) & (g2 >= (I - L))
  n_wa <- (0 >= R) & (I >= (I - alpha * Ca))
  n_wf <- (0 >= g1) & ((I - alpha * Ca) >= I)

  result <- rep("Absence of Pure Equilibrium", length(g1))
  result[n_wf] <- "Withdraw / Fight"
  result[n_wa & !n_wf] <- "Withdraw / Accept"
  result[n_if & !n_wa & !n_wf] <- "Implement / Fight"
  result[n_ia] <- "Implement / Accept"
  factor(result, levels = equilibrium_levels)
}

compute_payoffs <- function(R, LR, Cs, I, L, alpha, Ca, G, P) {
  g1 <- P * (R - LR - Cs - G) + (1 - P) * (-Cs)
  g2 <- (1 - P) * (I - Ca) + P * (I - L + G - Ca)

  matrix_tbl <- data.frame(
    offshore_action = c("Implement", "Implement", "Withdraw", "Withdraw"),
    surf_action = c("Accept", "Fight", "Accept", "Fight"),
    offshore_payoff = c(R, g1, 0, 0),
    surf_payoff = c(I - L, g2, I, I - alpha * Ca)
  )

  matrix_tbl$total_payoff <- matrix_tbl$offshore_payoff + matrix_tbl$surf_payoff
  matrix_tbl$better_for_offshore <- c(
    matrix_tbl$offshore_payoff[1] >= matrix_tbl$offshore_payoff[3],
    matrix_tbl$offshore_payoff[2] >= matrix_tbl$offshore_payoff[4],
    matrix_tbl$offshore_payoff[3] >= matrix_tbl$offshore_payoff[1],
    matrix_tbl$offshore_payoff[4] >= matrix_tbl$offshore_payoff[2]
  )
  matrix_tbl$better_for_surf <- c(
    matrix_tbl$surf_payoff[1] >= matrix_tbl$surf_payoff[2],
    matrix_tbl$surf_payoff[2] >= matrix_tbl$surf_payoff[1],
    matrix_tbl$surf_payoff[3] >= matrix_tbl$surf_payoff[4],
    matrix_tbl$surf_payoff[4] >= matrix_tbl$surf_payoff[3]
  )
  matrix_tbl$is_nash <- matrix_tbl$better_for_offshore & matrix_tbl$better_for_surf
  matrix_tbl$is_pareto_max <- matrix_tbl$total_payoff == max(matrix_tbl$total_payoff)
  matrix_tbl
}

grid_equilibria <- function(params, x_name, x_values, y_name, y_values) {
  grid <- expand.grid(
    x = x_values,
    y = y_values,
    KEEP.OUT.ATTRS = FALSE
  )

  p <- as.list(params)
  p[[x_name]] <- grid$x
  p[[y_name]] <- grid$y

  grid$equilibrium <- equilibrium_class(
    R = p$R, LR = p$LR, Cs = p$Cs, I = p$I, L = p$L,
    alpha = p$alpha, Ca = p$Ca, G = p$G, P = p$P
  )
  names(grid)[1:2] <- c(x_name, y_name)
  grid
}

area_evolution <- function(params, varying_name, varying_values, x_name = "P", y_name = "G",
                           x_values = seq(0, 1, length.out = 100),
                           y_values = seq(0, 1.5 * params[["L"]], length.out = 100)) {
  rows <- lapply(varying_values, function(v) {
    p <- params
    p[[varying_name]] <- v
    grid <- grid_equilibria(p, x_name, x_values, y_name, y_values)
    shares <- prop.table(table(factor(grid$equilibrium, levels = equilibrium_levels))) * 100
    data.frame(
      variable = varying_name,
      value = v,
      equilibrium = equilibrium_levels,
      area_percent = as.numeric(shares),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

write_csv <- function(data, filename) {
  write.csv(data, file.path(output_dir, filename), row.names = FALSE)
}

write_trace_csv <- function(data, filename) {
  write.csv(data, file.path(trace_dir, filename), row.names = FALSE)
}

save_png <- function(filename, width = 2400, height = 1800, res = 300) {
  png(file.path(figure_dir, filename), width = width, height = height, res = res)
}

plot_heatmap <- function(data, x_name, y_name, title, xlab, ylab, filename) {
  x_values <- sort(unique(data[[x_name]]))
  y_values <- sort(unique(data[[y_name]]))
  z <- matrix(as.integer(data$equilibrium), nrow = length(x_values), ncol = length(y_values))

  save_png(filename)
  par(mar = c(5, 5, 4, 8), family = "serif")
  image(
    x = x_values,
    y = y_values,
    z = z,
    col = unname(color_map),
    breaks = seq(0.5, length(equilibrium_levels) + 0.5, by = 1),
    xlab = xlab,
    ylab = ylab,
    main = title,
    useRaster = TRUE
  )
  grid(col = "gray85", lty = "dotted")
  legend(
    "right",
    inset = c(-0.55, 0),
    legend = equilibrium_levels,
    fill = unname(color_map),
    title = "Nash Equilibrium",
    xpd = TRUE,
    cex = 0.8,
    bty = "o"
  )
  dev.off()
}

plot_area <- function(data, title, xlab, filename) {
  save_png(filename, width = 3000, height = 1800)
  par(mar = c(5, 5, 4, 8), family = "serif")
  plot(
    NA,
    xlim = range(data$value),
    ylim = c(0, 100),
    xlab = xlab,
    ylab = "Area in the P vs G scenario grid (%)",
    main = title
  )
  grid(col = "gray85", lty = "dotted")
  for (eq in equilibrium_levels) {
    eq_data <- data[data$equilibrium == eq, ]
    if (max(eq_data$area_percent) > 0) {
      lines(eq_data$value, eq_data$area_percent, type = "o", lwd = 2, pch = 16, col = color_map[[eq]])
    }
  }
  legend(
    "right",
    inset = c(-0.55, 0),
    legend = equilibrium_levels,
    col = unname(color_map),
    lwd = 2,
    pch = 16,
    title = "Nash Equilibrium",
    xpd = TRUE,
    cex = 0.8,
    bty = "o"
  )
  dev.off()
}

copy_article_figure <- function(source_name, article_name) {
  invisible(file.copy(
    from = file.path(figure_dir, source_name),
    to = file.path(figure_dir, article_name),
    overwrite = TRUE
  ))
}

parameters_tbl <- build_parameters()
params <- as_params(parameters_tbl)
impact_scenarios <- c(
  "Low Impact" = 0.2 * params[["I"]],
  "Medium Impact" = 0.4 * params[["I"]],
  "High Impact" = 0.9 * params[["I"]]
)

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

p_values <- seq(0, 1, length.out = 100)
g_values_low <- seq(0, 1.5 * impact_scenarios[["Low Impact"]], length.out = 100)
low_params <- params
low_params[["L"]] <- impact_scenarios[["Low Impact"]]

pxg_low <- grid_equilibria(low_params, "G", g_values_low, "P", p_values)
plot_heatmap(
  pxg_low,
  "G",
  "P",
  "Sensitivity Analysis: Probability (P) vs. Compensation (G)",
  "Financial Compensation Offered (G)",
  "Probability of Offshore Institutional Success (P)",
  "probability_compensation_low_impact.png"
)
copy_article_figure("probability_compensation_low_impact.png", "grafico1.png")
write_trace_csv(pxg_low, "figure_01_probability_compensation_low_impact.csv")

ca_variations <- seq(-50, 50, by = 5)
for (scenario_name in names(impact_scenarios)) {
  scenario_params <- params
  scenario_params[["L"]] <- impact_scenarios[[scenario_name]]
  area <- area_evolution(
    scenario_params,
    varying_name = "Ca",
    varying_values = params[["Ca"]] * (1 + ca_variations / 100),
    y_values = seq(0, 1.5 * scenario_params[["L"]], length.out = 100)
  )
  area$variation_percent <- rep(ca_variations, each = length(equilibrium_levels))
  scenario_slug <- tolower(gsub(" ", "_", scenario_name))
  write_trace_csv(area, paste0("stakeholder_cost_area_", scenario_slug, ".csv"))
  plot_area(
    transform(area, value = variation_percent),
    paste("Evolution of Equilibrium Areas by Stakeholder Cost -", scenario_name),
    "Variation of Stakeholder Cost Ca (%)",
    paste0("stakeholder_cost_area_", scenario_slug, ".png")
  )
}
copy_article_figure("stakeholder_cost_area_low_impact.png", "grafico2.png")
copy_article_figure("stakeholder_cost_area_medium_impact.png", "grafico3.png")
copy_article_figure("stakeholder_cost_area_high_impact.png", "grafico4.png")

l_area <- area_evolution(
  params,
  varying_name = "L",
  varying_values = seq(0, 0.9 * params[["I"]], length.out = 21),
  y_values = seq(0, 1.5 * 0.9 * params[["I"]], length.out = 100)
)
write_trace_csv(l_area, "expected_local_loss_area.csv")
plot_area(
  l_area,
  "Evolution of Equilibrium Areas by Expected Local Loss",
  "Expected Local Loss L",
  "expected_local_loss_area.png"
)
copy_article_figure("expected_local_loss_area.png", "grafico5.png")

g_l_params <- params
g_l_grid <- grid_equilibria(
  g_l_params,
  "G",
  seq(0, 1.5 * params[["I"]], length.out = 100),
  "L",
  seq(0, 0.9 * params[["I"]], length.out = 100)
)
write_trace_csv(g_l_grid, "compensation_loss_heatmap.csv")
plot_heatmap(
  g_l_grid,
  "G",
  "L",
  "Strategic Frontier: Compensation (G) vs. Local Loss (L)",
  "Financial Compensation Offered (G)",
  "Expected Local Loss (L)",
  "compensation_loss_heatmap.png"
)
copy_article_figure("compensation_loss_heatmap.png", "grafico6.png")

lr_area <- area_evolution(
  low_params,
  varying_name = "LR",
  varying_values = seq(0, params[["R"]], length.out = 21),
  y_values = seq(0, 1.5 * low_params[["L"]], length.out = 100)
)
write_trace_csv(lr_area, "delay_cost_area_low_impact.csv")
plot_area(
  lr_area,
  "Evolution of Equilibrium Areas by Delay Cost - Low Impact",
  "Delay Cost LR",
  "delay_cost_area_low_impact.png"
)
copy_article_figure("delay_cost_area_low_impact.png", "grafico7.png")

for (scenario_name in c("Low Impact", "High Impact")) {
  scenario_params <- params
  scenario_params[["L"]] <- impact_scenarios[[scenario_name]]
  scenario_params[["G"]] <- scenario_params[["L"]]
  cost_grid <- grid_equilibria(
    scenario_params,
    "Ca",
    seq(0, params[["I"]], length.out = 100),
    "Cs",
    seq(0, params[["R"]], length.out = 100)
  )
  scenario_slug <- tolower(gsub(" ", "_", scenario_name))
  write_trace_csv(cost_grid, paste0("stakeholder_consortium_cost_heatmap_", scenario_slug, ".csv"))
  plot_heatmap(
    cost_grid,
    "Ca",
    "Cs",
    paste("Legal-Cost Asymmetry:", scenario_name),
    "Stakeholder Cost (Ca)",
    "Offshore Consortium Cost (Cs)",
    paste0("stakeholder_consortium_cost_heatmap_", scenario_slug, ".png")
  )
}
copy_article_figure("stakeholder_consortium_cost_heatmap_low_impact.png", "grafico8.png")
copy_article_figure("stakeholder_consortium_cost_heatmap_high_impact.png", "grafico9.png")

sensitivity_tbl <- expand.grid(
  P = seq(0.1, 0.9, by = 0.1),
  G = seq(0, 1.5 * params[["I"]], by = 1),
  Ca = seq(0, params[["I"]], by = 1),
  L = impact_scenarios,
  KEEP.OUT.ATTRS = FALSE
)
sensitivity_tbl$R <- params[["R"]]
sensitivity_tbl$LR <- params[["LR"]]
sensitivity_tbl$Cs <- params[["Cs"]]
sensitivity_tbl$I <- params[["I"]]
sensitivity_tbl$alpha <- params[["alpha"]]
sensitivity_tbl$offshore_conflict_payoff <- sensitivity_tbl$P *
  (sensitivity_tbl$R - sensitivity_tbl$LR - sensitivity_tbl$Cs - sensitivity_tbl$G) +
  (1 - sensitivity_tbl$P) * (-sensitivity_tbl$Cs)
sensitivity_tbl$surf_conflict_payoff <- (1 - sensitivity_tbl$P) *
  (sensitivity_tbl$I - sensitivity_tbl$Ca) +
  sensitivity_tbl$P * (sensitivity_tbl$I - sensitivity_tbl$L + sensitivity_tbl$G - sensitivity_tbl$Ca)
sensitivity_tbl$surf_accept_payoff <- sensitivity_tbl$I - sensitivity_tbl$L
sensitivity_tbl$fight_minus_accept <- sensitivity_tbl$surf_conflict_payoff - sensitivity_tbl$surf_accept_payoff
sensitivity_tbl$offshore_implements <- sensitivity_tbl$offshore_conflict_payoff > 0
sensitivity_tbl$surf_prefers_fight <- sensitivity_tbl$surf_conflict_payoff >= sensitivity_tbl$surf_accept_payoff

sensitivity_summary <- aggregate(
  cbind(surf_prefers_fight, offshore_implements) ~ P + G,
  data = sensitivity_tbl,
  FUN = mean
)
names(sensitivity_summary)[3:4] <- c("share_surf_prefers_fight", "share_offshore_implements")

figure_index <- data.frame(
  manuscript_file = paste0("images/grafico", 1:9, ".png"),
  artifact_file = file.path("simulation/outputs/article_figures", paste0("grafico", 1:9, ".png")),
  source_traceability = file.path(
    "simulation/outputs/traceability",
    c(
      "figure_01_probability_compensation_low_impact.csv",
      "stakeholder_cost_area_low_impact.csv",
      "stakeholder_cost_area_medium_impact.csv",
      "stakeholder_cost_area_high_impact.csv",
      "expected_local_loss_area.csv",
      "compensation_loss_heatmap.csv",
      "delay_cost_area_low_impact.csv",
      "stakeholder_consortium_cost_heatmap_low_impact.csv",
      "stakeholder_consortium_cost_heatmap_high_impact.csv"
    )
  ),
  description = c(
    "P x G equilibrium heatmap, low-impact scenario.",
    "P x G x Ca area evolution, low-impact scenario.",
    "P x G x Ca area evolution, medium-impact scenario.",
    "P x G x Ca area evolution, high-impact scenario.",
    "P x G x L area evolution.",
    "G x L equilibrium heatmap.",
    "P x G x LR area evolution, low-impact scenario.",
    "Ca x Cs equilibrium heatmap, low-impact scenario.",
    "Ca x Cs equilibrium heatmap, high-impact scenario."
  ),
  stringsAsFactors = FALSE
)

write_csv(parameters_tbl, "model_parameters.csv")
write_csv(baseline_payoff_tbl, "baseline_payoff_matrix.csv")
write_csv(sensitivity_tbl, "sensitivity_grid.csv")
write_csv(sensitivity_summary, "sensitivity_summary.csv")
write_csv(figure_index, "article_figure_index.csv")

figure_md <- c(
  "# Article Figure Traceability",
  "",
  "The active workflow is `simulation/r/run_peniche_offshore_analysis.R`. It reproduces the equilibrium-classification rule used in `simulation/notebooks/offshore_model_exploration.ipynb` and writes the manuscript figures to `simulation/outputs/article_figures/`.",
  "",
  "The Jupyter notebook is kept as an active exploratory interface. The R script is the deterministic workflow for regenerating article figures and CSV traceability files.",
  "",
  "| Manuscript figure | Artifact figure | Traceability data | Description |",
  "|---|---|---|---|",
  apply(
    figure_index,
    1,
    function(row) {
      paste0("| `", row[["manuscript_file"]], "` | `", row[["artifact_file"]], "` | `", row[["source_traceability"]], "` | ", row[["description"]], " |")
    }
  ),
  "",
  "Baseline parameters: `R=100`, `LR=20`, `Cs=2`, `I=22`, `L=4.4`, `alpha=0.1`, `Ca=3`, `G=4.4`, and `P=0.5`. Low, medium, and high impact scenarios set `L` to 20%, 40%, and 90% of `I`, respectively.",
  "",
  "Historical note: the original notebook widget default for `Ca` was 4.0. The active deterministic workflow uses `Ca=3` because that value is aligned with the current manuscript calibration and generated baseline payoff matrix."
)
writeLines(figure_md, file.path(output_dir, "article_figure_traceability.md"))

message("Outputs written to: ", output_dir)
message("Article figures written to: ", figure_dir)
