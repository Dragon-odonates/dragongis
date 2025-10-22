library(terra)
library(sf)
library(data.table)
library(here)

# Load data ---------------------------------------------------------------
df <- readRDS(here::here("data", "raw-data", "occ_all.rds"))
period <- 1990:2024 # time period of interest

# Transform dataset -------------------------------------------------------
# select based on year and full coordinates
df[, Year := year(eventDate)] # data.table syntax should be faster

keep <- !is.na(df$decimalLongitude) &
  !is.na(df$decimalLatitude) &
  df$Year %in% period
df <- df[keep, ]

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
    round(decimalLongitude / 10),
    round(decimalLatitude / 10),
    sep = "_"
  )
]

# create a vector of unique coordinates
vdf <- terra::vect(
  df,
  geom = c("decimalLongitude", "decimalLatitude"),
  crs = "EPSG:3035"
)

# use EEA 50km grid ---------------------------------------------------------------

grid <- vect(here("data", "raw-data", "EEA_50km.gpkg"))

# transformed from original grid into POLYGON
# grid <- st_read(here("data", "EEA_50km_grid_v2024.gpkg"))
# g2 <- st_cast(grid, "GEOMETRYCOLLECTION")
# g3 <- st_collection_extract(g2, "POLYGON")
# st_write(g3, here("data", "EEA_50km.gpkg"))

# get the id of the grid for each coordinate
id_grid <- terra::extract(grid, vdf)
df$gridID <- id_grid$cellcode #[match(df$coordinatesID, vcoo$coordinatesID)]


# Aggregate ---------------------------------------------------------------
ag <- aggregate(
  df$observationID,
  list(df$species, df$Year, df$gridID),
  FUN = function(x) length(unique(x))
)
names(ag) <- c("species", "year", "gridID", "n")

# remove grid cell with too few information
# obs_per_grid <- tapply(ag$n, ag$gridID, sum)
# # plot(cumsum(sort(obs_per_grid)), log = "y")
# keep_grid <- names(obs_per_grid)[obs_per_grid > 5]
ag <- ag[ag$gridID %in% keep_grid, ]

# Export data -------------------------------------------------------------
saveRDS(ag, here("data", "derived-data", "occ_grid_50km.rds"))
ag <- readRDS(here("data", "derived-data", "occ_grid_50km.rds"))

# export grid from EU
gridEU <- grid[grid$cellcode %in% ag$gridID, ]
writeVector(
  gridEU,
  here("data", "derived-data", "EU_grid_50km.gpkg"),
  overwrite = TRUE
)

# export points for visualization (projected lat/long)
pts <- centroids(gridEU)
# project to latlong
pts <- project(pts, "EPSG:4326")

writeVector(
  pts,
  here("data", "derived-data", "EU_points_50km.gpkg"),
  overwrite = TRUE
)
