#' dragongis: Getting the dataset and environmental covariate at 50km resolution
#'
#' @description
#' Getting the spatial dataset for the odonates dataset
#' on the 50km EEA grid
#'
#' @author Romain Frelat, Lisa Nicvert
#' @date 22 October 2025

## Install Dependencies (listed in DESCRIPTION) ----
if (!("remotes" %in% installed.packages())) {
  install.packages("remotes")
}
remotes::install_deps(upgrade = "never")


## Load Project Addins (R Functions) -------------
devtools::load_all()

## Run Project ----
start_global_timer <- Sys.time()

# 1. Use the EEA grid
start_prep_timer <- Sys.time()
source(here("analyses", "B1_transform_vect.R"))
end_prep_timer <- Sys.time()
duration_prep <- as.numeric(end_prep_timer - start_prep_timer, units = "mins")
paste("Data prep done in", round(duration_prep, 3), "min")
# Runs only on Rossinante (RAM issue), in XX min

# 2. Get the land cover per EEA grid
# Corine land cover, 100m, 2018, from
# https://land.copernicus.eu/en/products/corine-land-cover/clc2018
# https://doi.org/10.2909/960998c1-1870-4e82-8051-6485205ebbac
start_rast_timer <- Sys.time()
source(here("analyses", "B2_get_landcover.R"))
end_rast_timer <- Sys.time()
duration_rast <- as.numeric(end_rast_timer - start_rast_timer, units = "mins")
paste("Extracting land cover informations in", round(duration_rast, 3), "min")
# Data rast done in 0.75 min

# 3. Get the bioclimatic variables
# WorldClim 2, 1km, average 1970-2000, from
# Fick, S.E. and R.J. Hijmans, 2017.
# WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315
# https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_bio.zip
start_rast_timer <- Sys.time()
source(here("analyses", "B3_get_bioclim.R"))
end_rast_timer <- Sys.time()
duration_rast <- as.numeric(end_rast_timer - start_rast_timer, units = "mins")
paste("Extracting land cover informations in", round(duration_rast, 3), "min")
# Land cover extraction done in 2.8 min

# End global timer
end_global_timer <- Sys.time()

global_duration <- as.numeric(
  end_global_timer - start_global_timer,
  units = "mins"
)
paste("Total pipeline run in", round(global_duration, 3), "min")
# Total pipeline run in 16.161 min
