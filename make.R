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

# 1 Clean and format the observation dataset - create grids
source(here::here("analyses", "B1_transform_occ.R"))

# 2 Calculate summary per species
source(here::here("analyses", "B2_rasterspecies.R"))

# 3 Exploratory dashboard
quarto::quarto_render(here::here("analyses", "B3_explo_dashboard.qmd"))

# shiny app per species
shiny::runApp(appDir = "analyses/app")

# rsconnect::deployApp(appDir = "analyses/app",
#                      appFiles = list.files("analyses/app", recursive = TRUE),
#                      appName = "dragon-spdis",
#                      appTitle = "Dragon Species distribution")
# 5Mb bundle
