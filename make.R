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

# 1 Create grid from the observation dataset
source(here::here("analyses", "1_create_grid"))

# 2 Calculate number of observation and number of species per grid cell 
# for resolution 5km and 10km
source(here::here("analyses", "2_get_map.R"))
# for resolution 1km (and possibly lower)
source(here::here("analyses", "2bis_get_map_1000.R"))

# 3 Get other GIS information?
# to be defined ...