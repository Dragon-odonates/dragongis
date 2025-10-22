# Extract data from database
# This script works only on the computer hosting the Dragon database
# input:
#  raw-data/EEA_50km.gpkg
#  raw-data/U2018_CLC2018_V2020_20u1.tif
# output:
#  derived-data/CLC2018_50km.csv

library(terra)
library(sf)
library(exactextractr)
devtools::load_all()


# Load the EEA 50km grid with sf (only cells with observation)
grid <- st_read(here("data", "derived-data", "EU_grid_50km.gpkg"))

# Load the corine land cover with terra
clc <- rast(here("data", "raw-data", "U2018_CLC2018_V2020_20u1.tif"))
levels(clc$LABEL3)
# make the extraction with exactextractr
clc_50k <- exactextractr::exact_extract(
  clc,
  grid,
  fun = 'frac',
  progress = TRUE,
  append_cols = "cellcode"
)

# save full extraction
write.csv(
  clc_50k,
  here("data", "derived-data", "CLC2018_50km.csv"),
  row.names = FALSE
)
