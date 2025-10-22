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

# 1. Use the EEA grid
start_prep_timer <- Sys.time()
source(here("analyses", "B1_transform_vect.R"))
end_prep_timer <- Sys.time()
duration_prep <- as.numeric(end_prep_timer - start_prep_timer, units = "mins")
paste("Data prep done in", round(duration_prep, 3), "min")
# Runs only on Rossinante (RAM issue), in 7 min

# 2. Get the land cover per EEA grid
# Corine land cover, 100m, 2018, from
# https://land.copernicus.eu/en/products/corine-land-cover/clc2018
# https://doi.org/10.2909/960998c1-1870-4e82-8051-6485205ebbac
start_rast_timer <- Sys.time()
source(here("analyses", "B2_get_landcover.R"))
end_rast_timer <- Sys.time()
duration_rast <- as.numeric(end_rast_timer - start_rast_timer, units = "mins")
paste("Extracting land cover informations in", round(duration_rast, 3), "min")
# Land cover extraction done in 0.5 min

# 3. Get the bioclimatic variables
# Chelsa 2, 1km, average 1981-2010, from
# Karger, D.N., Conrad, O., Böhner, J., Kawohl, T., Kreft, H., Soria-Auza, R.W., Zimmermann, N.E., Linder, P., Kessler, M. (2017).
# Climatologies at high resolution for the Earth land surface areas. Scientific Data. 4 170122. https://doi.org/10.1038/sdata.2017.122
# https://chelsa-climate.org/
start_rast_timer <- Sys.time()
source(here("analyses", "B3_get_bioclim.R"))
end_rast_timer <- Sys.time()
duration_rast <- as.numeric(end_rast_timer - start_rast_timer, units = "mins")
paste("Extracting bioclimatic informations in", round(duration_rast, 3), "min")
# Bioclimatic extraction done in 0.1 min

# 4. Format environmental variables
start_rast_timer <- Sys.time()
source(here("analyses", "B4_format_env.R"))
end_rast_timer <- Sys.time()
duration_rast <- as.numeric(end_rast_timer - start_rast_timer, units = "mins")
paste("Formating env. data in", round(duration_rast, 3), "min")
# Formatting done in 0 min
