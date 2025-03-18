# Calculate the number of species and number of observation per pixel
# from the grids and observation transformed in 1_create_grid.R

# memory overload for grid size of 1km
# solution: saving the temporary rasters

# system.time({source("analyses/2bis_get_map_1000.R")})
# time : 8 min, memory usage 13gb 

library(sf)
library(terra)

# set the resolution: 1km
res <- "1km"

grid <- readRDS(here::here("data", "derived-data", paste0("grid_",res, ".rds")))
vobs <- readRDS(here::here("data", "derived-data", "vect_obs.rds"))

# set the time extent (last 30 years)
time_ext <- 1995:2024
# set the function to calculate the number of unique elements
nodup <- function(x) {return(sum(!duplicated(x)))}
# faster than length(unique(x))

# create temporary directory to keep raster
dirtemp <- here::here("data", paste("temp", res, sep="_"))
if (!dir.exists(dirtemp)){
  dir.create(dirtemp)
}


for (i in seq_along(time_ext)){
  # get the observation of year i
  vi <- vobs[vobs$Year==time_ext[i],]

  # get the number of observations (unique id)
  nobs <- rasterize(vi, grid, field='ID', fun=nodup)

  # get the species richness (number of unique species)
  nspe <- rasterize(vi, grid, field='species', fun=nodup)

  out <- rast(list(nobs, nspe))
  names(out) <- c(paste("nobs", time_ext[i], sep="_"),
                  paste("nspe", time_ext[i], sep="_"))

  terra::writeRaster(out, 
    here::here(dirtemp, paste0("meta_",time_ext[i], "_", res, ".tif")),
    overwrite=TRUE)
}


# reharmonize dataset

# free up some memory
rm(out, vobs, grid, vi)
# list all rasters
ltif <- list.files(dirtemp, pattern = "tif$", full.names = TRUE)
# load all rasters
full <- terra::rast(ltif)
# export it as a unique geotiff
terra::writeRaster(full, here::here("data", "derived-data", paste0("meta_", res, ".tif")), 
                   overwrite=TRUE)

# remove the temporary file in 'temp1km' folder
# unlink(dirtemp, recursive = TRUE)