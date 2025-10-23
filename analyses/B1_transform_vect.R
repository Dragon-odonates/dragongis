# Transform occurrence data on 50km grid
# usefull for shinyapp (but not needed for further modelling)
# input:
#  raw-data/occ_all.rds
#  raw-data/EEA_50km.gpkg
# output:
#  derived-data/occ_grid_50km.rds
#  derived-data/EU_grid_50km.gpkg
#  derived-data/EU_points_50km.gpkg

library(rnaturalearth)
devtools::load_all()

# List of countries to get the grid for
country_list <- c("Austria", "Belgium", "Cyprus", "Czechia",
                  "Denmark", "Finland", "France", "Germany",
                  "Ireland", "Italy", "Luxemburg", "Netherlands",
                  "Norway", "Slovenia", "Spain", "Sweden", "Switzerland",
                  "United Kingdom")

gridsize <- 50000

gridsize_km <- gridsize/1000
gridfile_read <- paste0("EEA_",gridsize_km ,"km_grid_v2024.gpkg")

# # Load data ---------------------------------------------------------------
# df <- readRDS(here::here("data", "raw-data", "occ_all.rds"))
# period <- 1990:2024 # time period of interest
# 
# # Transform dataset -------------------------------------------------------
# # select based on year and full coordinates
# df[, Year := year(eventDate)] # data.table syntax should be faster
# 
# keep <- !is.na(df$decimalLongitude) &
#   !is.na(df$decimalLatitude) &
#   df$Year %in% period
# df <- df[keep, ]
# 
# # remove coordinates that are obviously not in EU
# checklong <- df$decimalLongitude > 2000000 & df$decimalLongitude < 7000000
# checklat <- df$decimalLatitude > 1000000 & df$decimalLatitude < 6000000
# df <- df[checklong & checklat, ]
# 
# # add an id for coordinates
# df[, coordinatesID := paste(decimalLongitude, decimalLatitude, sep = "_")]
# 
# # add dataset ID
# df[, dbID := ifelse(is.na(parentDatasetID), datasetID, parentDatasetID)]
# 
# # add observation id
# df[,
#   observationID := paste(
#     eventDate,
#     dbID,
#     recorderID,
#     round(decimalLongitude / 10),
#     round(decimalLatitude / 10),
#     sep = "_"
#   )
# ]
# 
# # create a vector of unique coordinates
# vdf <- terra::vect(
#   df,
#   geom = c("decimalLongitude", "decimalLatitude"),
#   crs = "EPSG:3035"
# )

# Get EEA 50km grid ---------------------------------------------------------------

# Original file downloaded from https://sdi.eea.europa.eu/catalogue/srv/api/records/aac8379a-5c4e-445c-b2ef-23a6a2701ef0?language=all
g1 <- st_read(here("data", "raw-data", gridfile_read))

# transformed from original grid into POLYGON
g2 <- st_cast(g1, "GEOMETRYCOLLECTION")
grid_vect <- st_collection_extract(g2, "POLYGON")
# st_write(grid, here("data", "raw-data", "EEA_50km.gpkg"),
#          append=FALSE)
# grid_vect <- vect(here("data", "raw-data", "EEA_50km.gpkg"))

# Convert to raster (more lightweight)
grid <- rast(grid_vect, res = gridsize)

# # get the id of the grid for each coordinate
# id_grid <- terra::extract(grid, vdf)
# df$gridID <- id_grid$cellcode #[match(df$coordinatesID, vcoo$coordinatesID)]

# Get countries vectors ---------------------------------------------------

# Get countries borders
extent <- ne_countries(country = country_list,
                       scale = 50)

# Crop data to continental Europe
europe_bbox <- c(xmin = -13.0, xmax = 35.7, 
                 ymin = 33.8, ymax = 72.0)
extent <- st_crop(extent, europe_bbox)

# Change CRS
extent <- st_transform(extent, 3035)

# Create terra object
vext <- terra::vect(extent)

# Plot
plot(vext)

# Crop grid to countries extent -------------------------------------------

# Project bbox in 3035
europe_bbox_3035 <- project(ext(europe_bbox), 
                            from = "EPSG:4326", to = "EPSG:3035")
plot(europe_bbox_3035, col = "purple")
lines(vext)

# Crop raster to Europe
grid_crop <- crop(grid, europe_bbox_3035)

# Create grid ID
grid_id <- 1:ncell(grid_crop)
grid_crop <- setValues(grid_crop, grid_id)
names(grid_crop) <- "grid_id"

plot(grid_crop)
lines(vext)

# # Aggregate ---------------------------------------------------------------
# ag <- aggregate(
#   df$observationID,
#   list(df$species, df$Year, df$gridID),
#   FUN = function(x) length(unique(x))
# )
# names(ag) <- c("species", "year", "gridID", "n")
# 
# # remove grid cell with too few information
# # obs_per_grid <- tapply(ag$n, ag$gridID, sum)
# # # plot(cumsum(sort(obs_per_grid)), log = "y")
# # keep_grid <- names(obs_per_grid)[obs_per_grid > 5]
# # ag <- ag[ag$gridID %in% keep_grid, ]
# 
# # Export data -------------------------------------------------------------
# saveRDS(ag, here("data", "derived-data", "occ_grid_50km.rds"))
# # ag <- readRDS(here("data", "derived-data", "occ_grid_50km.rds"))

# export grid from EU
# gridEU <- grid[grid$cellcode %in% ag$gridID, ]

# Export grid -------------------------------------------------------------
gridfile_write <- paste0("EU_grid_", gridsize_km, "km_crop.gpkg")

writeVector(
  grid_crop,
  here("data", "derived-data", gridfile_write),
  overwrite = TRUE
)

# # export points for visualization (projected lat/long)
# pts <- centroids(gridEU)
# # project to latlong
# pts <- project(pts, "EPSG:4326")
# 
# writeVector(
#   pts,
#   here("data", "derived-data", "EU_points_50km.gpkg"),
#   overwrite = TRUE
# )
