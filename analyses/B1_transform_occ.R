# Load the raw data of observations
# create raster, shapefile, and derived dataset


# 0. Load library and data, set parameters ------------
# load spatial packages
library(terra)
library(sf)

# load data
df <- readRDS(here::here("data", "raw-data", "occ_all_sf.rds"))
# nrow(df) # 12536646
# set parameters
period <- 1990:2024 # time period of interest
res_grid <- 10000 # grid resolution


# 1. transform dataset --------------------------------
# simplify spatial geometry
# filter only point geometry (too few other type ...)
stype <- st_geometry_type(df$decimalCoordinates, by_geometry = TRUE)
# table(stype, useNA="ifany")
df <- dplyr::filter(df, stype%in%"POINT")

# keep coordinates in data.frame
df$long_3035 <- sapply(df$decimalCoordinates, function(x) x[[1]])
df$lat_3035 <- sapply(df$decimalCoordinates, function(x) x[[2]])

# remove the sf feature (to speed up data manipulation)
df <- sf::st_set_geometry(df, NULL)

# select based on year and full coordinates
df$Year <- format(as.Date(df$eventDate), "%Y")
# faster than df$Year <- substr(df$eventDate, 1, 4)

keep <- !is.na(df$long_3035) & !is.na(df$lat_3035) & df$Year %in% period
df <- dplyr::filter(df, keep)

# remove coordinates that are obviously not in EU
checklong <- df$long_3035>2000000 & df$long_3035 <7000000 
checklat <- df$lat_3035>1000000 & df$lat_3035 <6000000
df <- dplyr::filter(df, checklong & checklat)

# add an id for coordinates
df$coordinatesID <- paste(df$long_3035, df$lat_3035, sep="_")

# add dataset ID
df$dbID <- ifelse(is.na(df$parentDatasetID),df$datasetID, df$parentDatasetID)

# add country
df$Country <- substr(df$dbID, 1, 2)
# table(df$Country) # to be cleaned (CA and AT are not country)

# add observation id
df$observationID <- paste(df$eventDate, df$dbID, df$recorderID, round(df$long_3035/100), round(df$lat_3035/100), sep="_")

# get taxonomy from gbif and add family
splist <- sort(unique(df$species))
gbiflist <- rgbif::name_backbone_checklist(splist)
# table(gbiflist$canonicalName == splist)
df$family <- gbiflist$family[match(df$species, splist)]
df$genus <- gbiflist$genus[match(df$species, splist)]


# create a vector of unique coordinates
coo <- cbind(df$long_3035, df$lat_3035)
coo <- coo[!duplicated(coo),]
vcoo <- terra::vect(coo, crs="EPSG:3035")

# add the coordinatesID
vcoo$coordinatesID <- paste(coo[,1], coo[,2], sep="_")

# make a 10km grid
grid10 <- terra::rast(vcoo, res=res_grid)
terra::values(grid10) <- 1:terra::ncell(grid10)

# saveRDS(df, here::here("data", "derived-data", "occ_all_temp.rds"))
# saveRDS(coo, here::here("data", "derived-data", "coo_temp.rds"))
# df <- readRDS(here::here("data", "derived-data", "occ_all_temp.rds"))
# grid10 <- readRDS(here::here("data", "derived-data", "grid_10000.rds"))

# get the id of the grid for each coordinate
id_grid <- terra::extract(grid10, vcoo)
# id_grid <- exactextractr::exact_extract(grid10, sf::st_as_sf(vcoo), progress=TRUE)
df$grid10kmID <- id_grid$lyr.1[match(df$coordinatesID, vcoo$coordinatesID)]

# export
saveRDS(df, here::here("data", "derived-data", "occ_all_df.rds"))
saveRDS(grid10, here::here("data", "derived-data", paste0("grid_", res_grid,".rds")))
# saveRDS(df, here::here("data", "derived-data", "occ_all_df_xz.rds"), compress="xz")
# qs::qsave(df, here::here("data", "derived-data", "occ_all_df.qs"), preset = "high")

# system.time({source("analyses/B2_rasterspecies.R")})
# 5 min, 14gb