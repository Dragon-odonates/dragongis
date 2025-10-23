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
                  "Ireland", "Italy", "Luxembourg", "Netherlands",
                  "Norway", "Slovenia", "Spain", "Sweden", "Switzerland",
                  "United Kingdom")

gridsize <- 50000

gridsize_km <- gridsize/1000
gridfile_read <- paste0("EEA_",gridsize_km ,"km_grid_v2024.gpkg")

# Get EEA 50km grid ---------------------------------------------------------------

# Original file downloaded from https://sdi.eea.europa.eu/catalogue/srv/api/records/aac8379a-5c4e-445c-b2ef-23a6a2701ef0?language=all
g1 <- st_read(here("data", "raw-data", gridfile_read))

# transformed from original grid into POLYGON
g2 <- st_cast(g1, "GEOMETRYCOLLECTION")
grid <- st_collection_extract(g2, "POLYGON")
grid <- vect(grid)

# Get countries vectors ---------------------------------------------------

# Get countries borders
countries <- ne_countries(country = country_list,
                          scale = 50)

# Crop data to continental Europe
europe_bbox <- c(xmin = -13.0, xmax = 35.7, 
                 ymin = 33.8, ymax = 72.0)
countries <- st_crop(countries, europe_bbox)

# Change CRS
countries <- st_transform(countries, 3035)

# Create terra object
countries <- terra::vect(countries)
countries_united <- terra::aggregate(countries)

# Plot
plot(countries)
lines(countries_united, col = "purple")

# Crop grid to countries extent -------------------------------------------

# Get grid cells intersecting countries
rel <- relate(grid, countries_united, "intersects")

# Get index of intersecting polygons
grid_crop <- grid[rel[, 1], ]

# Create grid ID
grid_id <- 1:ncell(grid_crop)
grid_crop <- setValues(grid_crop, grid_id)
names(grid_crop) <- "grid_id"

plot(grid_crop)
lines(countries)

# Export grid -------------------------------------------------------------
gridfile_write <- paste0("EU_grid_", gridsize_km, "km_crop.gpkg")

writeVector(
  grid_crop,
  here("data", "derived-data", gridfile_write),
  overwrite = TRUE
)
