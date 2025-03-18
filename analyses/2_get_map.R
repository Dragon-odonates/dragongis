# Calculate the number of species and number of observation per pixel
# from the grids and observation transformed in 1_create_grid.R

# run for 5km and 10km grid, but not for 1km (with 16gb of ram)
# for 1km grid, please run get_map_1000.R with smaller exports

# system.time({source("analyses/2_get_map.R")})
# 10km : 237 sec, 8gb
# 5km : 235 sec, 10gb
# all together : 8 min, 12gb 

library(sf)
library(terra)

# set the function to calculate the number of unique elements
nodup <- function(x) {return(sum(!duplicated(x)))}
# faster than length(unique(x))

# set the time extent (last 30 years)
time_ext <- 1995:2024

# loop on the resolution (1km, 5km, or 10km)
# sadly does't work with resolution 1km due to memory overload
for (r in c("10", "5")){
  # load the grid
  grid <- readRDS(here::here("data", "derived-data", paste0("grid_",r, "km.rds")))

  # load the vector
  vobs <- readRDS(here::here("data", "derived-data", "vect_obs.rds"))

  nobs <- list()
  nspe <- list()

  for (i in seq_along(time_ext)){
    # get the observation of year i
    vi <- vobs[vobs$Year==time_ext[i],]

    # get the number of observations (unique id)
    nobs[[i]] <- rasterize(vi, grid, field='ID', fun=nodup)

    # get the species richness (number of unique species)
    nspe[[i]] <- rasterize(vi, grid, field='species', fun=nodup)
  }
  
  # rename list of rasters 
  names(nobs) <- paste("nobs", time_ext, sep="_")
  names(nspe) <- paste("nspe", time_ext, sep="_")

  # create stack of raster per grid size
  out <- c(rast(nobs), rast(nspe))

  # export it
  terra::writeRaster(out, 
    here::here("data", "derived-data", paste0("meta_", r, "km.tif")),
    overwrite=TRUE)
}
