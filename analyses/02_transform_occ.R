# Load the raw data of observations
# create raster, shapefile, and derived dataset

# input:
#  raw-data/occ_all.rds : occurrences from 01_extract_data.R
# output:
#  derived-data/occ_all_df.rds : processed occurrences with grid10kmID
#  derived-data/grid_10000.rds : raster grid at 10km

# Libraries ---------------------------------------------------------------
library(terra)
library(sf)
library(data.table)


# Load data ---------------------------------------------------------------

df <- readRDS(here::here("data", "raw-data", "occ_all.rds"))
# nrow(df) # 12442338
# set parameters
period <- 1990:2024 # time period of interest
res_grid <- 10000 # grid resolution


# Transform dataset -------------------------------------------------------

# select based on year and full coordinates
df[, Year := year(eventDate)] # data.table syntax should be faster

keep <- !is.na(df$decimalLongitude) &
  !is.na(df$decimalLatitude) &
  df$Year %in% period
df <- df[keep, ]
# way faster than system.time({df1 <- dplyr::filter(df, keep)})

# remove coordinates that are obviously not in EU
checklong <- df$decimalLongitude > 2000000 & df$decimalLongitude < 7000000
checklat <- df$decimalLatitude > 1000000 & df$decimalLatitude < 6000000
df <- df[checklong & checklat, ]

# add an id for coordinates
df[, coordinatesID := paste(decimalLongitude, decimalLatitude, sep = "_")]

# add dataset ID
df[, dbID := ifelse(is.na(parentDatasetID), datasetID, parentDatasetID)]

# add observation id
df[,
  observationID := paste(
    eventDate,
    dbID,
    recorderID,
    round(decimalLongitude / 100),
    round(decimalLatitude / 100),
    sep = "_"
  )
]

# create a vector of unique coordinates
coo <- cbind(df$decimalLongitude, df$decimalLatitude)
coo <- coo[!duplicated(coo), ]
vcoo <- terra::vect(coo, crs = "EPSG:3035")

# add the coordinatesID
vcoo$coordinatesID <- paste(coo[, 1], coo[, 2], sep = "_")


# Make grid ---------------------------------------------------------------

# make a 10km grid
grid10 <- terra::rast(vcoo, res = res_grid)
terra::values(grid10) <- 1:terra::ncell(grid10)

# get the id of the grid for each coordinate
id_grid <- terra::extract(grid10, vcoo)
df$grid10kmID <- id_grid$lyr.1[match(df$coordinatesID, vcoo$coordinatesID)]

# Create a factor
df[, grid10kmID := factor(grid10kmID, levels = 1:ncell(grid10))]

# Export data -------------------------------------------------------------

saveRDS(df, here::here("data", "derived-data", "occ_all_df.rds"))
saveRDS(
  grid10,
  here::here("data", "derived-data", paste0("grid_", res_grid, ".rds"))
)
