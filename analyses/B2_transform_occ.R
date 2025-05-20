# Load the raw data of observations
# create raster, shapefile, and derived dataset


# 0. Load library and data, set parameters ------------
# load spatial packages
library(terra)
library(sf)
library(data.table)

# load data
df <- readRDS(here::here("data", "raw-data", "occ_sub.rds"))
# df_sub <- df[sample(1:nrow(df), size = 1000000, replace = FALSE),]
# saveRDS(df_sub, here::here("data", "raw-data", "occ_sub_sf.rds"))
# nrow(df) # 12442338
# set parameters
period <- 1990:2024 # time period of interest
res_grid <- 10000 # grid resolution


# 1. transform dataset --------------------------------

# select based on year and full coordinates
df[, Year := year(eventDate)] # data.table syntax should be faster

keep <- !is.na(df$decimalLongitude) & !is.na(df$decimalLatitude) & df$Year %in% period
df <- df[keep, ]
# way faster than system.time({df1 <- dplyr::filter(df, keep)})

# remove coordinates that are obviously not in EU
checklong <- df$decimalLongitude > 2000000 & df$decimalLongitude < 7000000 
checklat <- df$decimalLatitude > 1000000 & df$decimalLatitude < 6000000
df <- df[checklong & checklat, ]

# add an id for coordinates
df[, coordinatesID := paste(decimalLongitude, 
                            decimalLatitude, sep = "_")]

# add dataset ID
df[, dbID := ifelse(is.na(parentDatasetID),
                    datasetID, 
                    parentDatasetID)]

# add country
df[, Country := substr(dbID, 1, 2)]
# table(df$Country) # to be cleaned (CA and AT are not country)

# add observation id
df[, observationID := paste(eventDate, dbID, recorderID, 
                            round(decimalLongitude/100), round(decimalLatitude/100), 
                            sep = "_")]

# create a vector of unique coordinates
coo <- cbind(df$decimalLongitude, df$decimalLatitude)
coo <- coo[!duplicated(coo),]
vcoo <- terra::vect(coo, crs="EPSG:3035")

# add the coordinatesID
vcoo$coordinatesID <- paste(coo[ ,1], coo[ ,2], sep = "_")

# make a 10km grid
grid10 <- terra::rast(vcoo, res = res_grid)
terra::values(grid10) <- 1:terra::ncell(grid10)

# get the id of the grid for each coordinate
id_grid <- terra::extract(grid10, vcoo)
df$grid10kmID <- id_grid$lyr.1[match(df$coordinatesID, vcoo$coordinatesID)]

# export
saveRDS(df, here::here("data", "derived-data", "occ_all_df.rds"))
saveRDS(grid10, here::here("data", "derived-data", paste0("grid_", res_grid,".rds")))

# system.time({source("analyses/B2_rasterspecies.R")})
# 5 min, 14gb