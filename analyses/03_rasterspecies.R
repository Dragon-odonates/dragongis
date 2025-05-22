# Derive spatial statistics for species


# Libraries ---------------------------------------------------------------
library(here)
library(collapse)
library(data.table)

library(terra)
library(sf)


funcdir <- here("functions")
source(here(funcdir, "functions.R"))

# Get data ----------------------------------------------------------------
res_grid <- 10000

df <- readRDS(here::here("data", "derived-data", "occ_all_df.rds"))
grid10 <- readRDS(here::here("data", "derived-data", 
                             paste0("grid_", res_grid,".rds")))

# Compute spatial statistics -----------------------------

# calculate overall statistics per grid cell
# number of species per cell
spe_grid <- tapply(df$species, df$grid10kmID, 
                   function(x) nodup(x, na.rm = FALSE))

# number of observation per cell
obs_grid <- tapply(df$observationID, df$grid10kmID, nodup)

# number of observation per cell
year_grid <- tapply(df$Year, df$grid10kmID, nodup)

# set into the grid
nspe <- setValues(grid10, as.numeric(spe_grid))
names(nspe) <- "nspe"
nobs <- setValues(grid10, as.numeric(obs_grid))
names(nobs) <- "nobs"
nyr <- setValues(grid10, as.numeric(year_grid))
names(nyr) <- "nyr"
# nyr5 <- setValues(grid10, as.numeric(year5_grid))
# names(nyr5) <- "nyr5"

# merge into a single raster file
statrast <- c(nspe, nobs, nyr)#, nyr5)

# export the raster
saveRDS(statrast, here::here("data", "derived-data", 
                             paste0("stat_", res_grid,".rds")))