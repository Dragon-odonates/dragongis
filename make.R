#' dragongis: A Research Compendium
#'
#' @description
#' Spatial analysis of the odonates database
#'
#' @author Romain Frelat
#' @date 18 March 2025


## Install Dependencies (listed in DESCRIPTION) ----

if (!("remotes" %in% installed.packages())) {
  install.packages("remotes")
}

remotes::install_deps(upgrade = "never")


## Load Project Addins (R Functions) -------------

devtools::load_all(here::here())


## Run Project ----
start_global_timer <- Sys.time()

# 1 Clean and format the observation dataset - create grids
start_prep_timer <- Sys.time()
source(here::here("analyses", "02_transform_occ.R"))
end_prep_timer <- Sys.time()
duration_prep <- as.numeric(end_prep_timer - start_prep_timer, units = "secs")/60
paste("Data prep done in", round(duration_prep, 3), "min") # Data prep done in 7.433 min

# 2 Calculate summary per species
start_rast_timer <- Sys.time()
source(here::here("analyses", "03_rasterspecies.R"))
end_rast_timer <- Sys.time()
duration_rast <- as.numeric(end_rast_timer - start_rast_timer, units = "secs")/60
paste("Data rast done in", round(duration_rast, 3), "min") # Data rast done in 0.75 min

# 2bis Calculate species accumulation curves
# source(here::here("analyses", "03bis_speciesacc.R"))

# 3 Exploratory dashboard
start_qmd_timer <- Sys.time()
quarto::quarto_render(here::here("analyses", "04_explo_dashboard.qmd"))
end_qmd_timer <- Sys.time()
duration_qmd <- as.numeric(end_qmd_timer - start_qmd_timer, units = "secs")/60
paste("Dashboard done in", round(duration_qmd, 3), "min") # Dashboard done in 2.203 min


# 4 Prepare Shiny app data
start_shiny_timer <- Sys.time()
source(here::here("analyses", "05_data_for_app.R"))
end_shiny_timer <- Sys.time()
duration_shiny <- as.numeric(end_shiny_timer - start_shiny_timer, units = "secs")/60
paste("Shiny app data preparation done in", round(duration_shiny, 3), "min") # "Shiny app data preparation done in 5.775 min

# End global timer
end_global_timer <- Sys.time()

global_duration <- as.numeric(end_global_timer - start_global_timer, units = "secs")/60
paste("Total pipeline run in", round(global_duration, 3), "min")
# Total pipeline run in 16.161 min

# shiny app per species
# shiny::runApp(appDir = "analyses/app")

# rsconnect::deployApp(appDir = "analyses/app",
#                      appFiles = list.files("analyses/app", recursive = TRUE),
#                      appName = "dragon-spdis",
#                      appTitle = "Dragon Species distribution")
# 5Mb bundle
