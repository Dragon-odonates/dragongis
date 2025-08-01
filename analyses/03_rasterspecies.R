# Derive spatial statistics for species

# input:
#   derived-data/occ_all_df.rds : processed occurrences from 02_transform_occ.R
#   derived-data/grid_10000.rds : raster grid from 02_transform_occ.R
# output:
#   derived-data/stat_10000.rds" : raster with statistics per cell
#   derived-data/cells_10000.rds" : vector with points per species per year

# Libraries ---------------------------------------------------------------
devtools::load_all()
# equivalent to:
# library(here)
# library(collapse)
# library(data.table)

# library(terra)
# library(sf)

# source(here("R", "functions.R"))

# Get data ----------------------------------------------------------------
res_grid <- 10000

df <- readRDS(here::here("data", "derived-data", "occ_all_df.rds"))
grid10 <- readRDS(
  here::here("data", "derived-data", paste0("grid_", res_grid, ".rds"))
)

# Compute spatial statistics -----------------------------

# calculate overall statistics per grid cell
# number of species per cell
spe_grid <- tapply(df$species, df$grid10kmID, nodup, na.rm = FALSE)

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

# merge into a single raster file
statrast <- c(nspe, nobs, nyr)

# export the raster
saveRDS(
  statrast,
  here::here("data", "derived-data", paste0("stat_", res_grid, ".rds"))
)


# Create simple shapefile ------------------------------------
# get one line per species x year x observation
gridspyr <- paste(df$grid10kmID, df$species, df$Year, sep = "_")
n_gridspyr <- table(gridspyr)
out <- strsplit(names(n_gridspyr), "_")

pts_df <- data.frame(
  "grid10kmID" = as.numeric(sapply(out, function(x) x[[1]])),
  "species" = sapply(out, function(x) x[[2]]),
  "year" = as.numeric(sapply(out, function(x) x[[3]])),
  "n" = as.numeric(n_gridspyr)
)
# remove NAs
pts_df <- pts_df[complete.cases(pts_df), ]
# get coordinates from grid10
pts_coo <- crds(grid10)[pts_df$grid10kmID, ]
# create shapefile
shp <- vect(pts_coo, atts = pts_df, crs = crs(grid10))
# project to lon/lat WGS84
shp <- project(shp, "EPSG:4326")
# transform as sf object (easier to read with Leaflet)
shp <- st_as_sf(shp)
# export
saveRDS(
  shp,
  here::here("data", "derived-data", paste0("cells_", res_grid, ".rds"))
)
