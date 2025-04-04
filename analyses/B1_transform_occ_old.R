# Load the raw data of observations
# create raster, shapefile, and derived dataset


# 0. Load library and data, set parameters ------------
# load spatial packages
library(terra)
library(sf)

# set the function to calculate the number of unique elements
nodup <- function(x) {return(sum(!duplicated(x)))}

# load data
tab <- readRDS(here::here("data", "raw-data", "occ_all_sf.rds"))
nrow(tab) #12536646
# set parameters
period <- 1990:2024 # time period of interest
res_grid <- 10000 # grid resolution


# 1. transform dataset --------------------------------

# simplify spatial geometry
tab <- sf::st_centroid(tab)
# get the coordinates of centroid
coo <- sf::st_coordinates(tab$decimalCoordinates)
# remove the sf feature (to speed up data manipulation)
df <- sf::st_set_geometry(tab, NULL)
# keep coordinates in data.frame
df$long_3035 <- coo[,1]
df$lat_3035 <- coo[,2]

# select based on year and full coordinates
df$Year <- substr(df$eventDate, 1, 4)
keep <- !is.na(df$long_3035) & !is.na(df$lat_3035) & df$Year %in% period
df <- dplyr::filter(df, keep)

# remove coordinates that are obviously not in EU
poscoo <- df$long_3035>0 & df$lat_3035>0
df <- dplyr::filter(df, poscoo)

# remove the decimalCoordinates column
df <- df[,!names(df)=="decimalCoordinates"]

# add an id for coordinates
df$coordinatesID <- paste(df$long_3035, df$lat_3035, sep="_")

# create a vector of unique coordinates
coo <- cbind(df$long_3035, df$lat_3035)
coo <- coo[!duplicated(coo),]
vcoo <- terra::vect(coo, crs="EPSG:3035")

# add the coordinatesID
vcoo$coordinatesID <- paste(coo[,1], coo[,2], sep="_")

# make a 10km grid
grid10 <- terra::rast(vcoo, res=res_grid)
values(grid10) <- 1:ncell(grid10)

# get the id of the grid for each coordinate
id_grid <- terra::extract(grid10, vcoo)
df$grid10kmID <- id_grid$lyr.1[match(df$coordinatesID, vcoo$coordinatesID)]

# add dataset ID
df$dbID <- ifelse(is.na(df$parentDatasetID),df$datasetID, df$parentDatasetID)
df$dbID[is.na(df$dbID)] <- "SWNA"

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

# export
saveRDS(df, here::here("data", "derived-data", "occ_all_df.rds"))
saveRDS(grid10, here::here("data", "derived-data", paste0("grid_", res_grid,".rds")))

# 2. compute spatial statistics -----------------------------
# transform gridID as factor with all cell values
df$gridfac <- factor(df$grid10kmID, levels=1:ncell(grid10))

## calculate overall statistics per grid cell
# number of species per cell
spe_grid <- tapply(df$species, df$gridfac, nodup)

# number of observation per cell
obs_grid <- tapply(df$observationID, df$gridfac, nodup)

# number of observation per cell
year_grid <- tapply(df$Year, df$gridfac, nodup)

# number of observation per year and per cell
yearobs_grid <- tapply(df$observationID, list(df$Year, df$gridfac), nodup)
year5_grid <- apply(yearobs_grid>5, 2, sum, na.rm=TRUE)
year5_grid[is.na(year_grid)] <- NA

# set into the grid
nspe <- setValues(grid10, as.numeric(spe_grid))
names(nspe) <- "nspe"
nobs <- setValues(grid10, as.numeric(obs_grid))
names(nobs) <- "nobs"
nyr <- setValues(grid10, as.numeric(year_grid))
names(nyr) <- "nyr"
nyr5 <- setValues(grid10, as.numeric(year5_grid))
names(nyr5) <- "nyr5"

# merge into a single raster file
statrast <- c(nspe, nobs, nyr, nyr5)
# export the raster
saveRDS(statrast, here::here("data", "derived-data", paste0("stat_", res_grid,".rds")))


## calculate species observation per grid cell
n <- table(df$species)
ngrid <- table(df$gridfac)
nrast <- nspe
prast <- nobs
yrast <- nyr
for (s in names(n)[n>10000]){
  ms <- df$species==s
  # percentage obs per grid cell
  n_grid <- table(df$gridfac[ms])
  n_grid[is.na(obs_grid)] <- NA
  ns <- setValues(grid10, as.numeric(n_grid))
  # percentage obs per grid cell
  p_grid <- tapply(df$observationID[ms], df$gridfac[ms], nodup)/obs_grid*100
  ps <- setValues(grid10, as.numeric(p_grid))
  # percentage year per grid cell
  y_grid <- tapply(df$Year[ms], df$gridfac[ms], nodup)/year_grid*100
  ys <- setValues(grid10, as.numeric(y_grid))

  nrast <- c(nrast, ns)
  names(nrast)[nlyr(nrast)] <- s
  prast <- c(prast, ps)
  names(prast)[nlyr(prast)] <- s
  yrast <- c(yrast, ys)
  names(yrast)[nlyr(yrast)] <- s
}

# export the species output
saveRDS(nrast, here::here("data", "derived-data", paste0("species_", res_grid,".rds")))
saveRDS(prast, here::here("data", "derived-data", paste0("percobs_", res_grid,".rds")))
saveRDS(yrast, here::here("data", "derived-data", paste0("percyear_", res_grid,".rds")))
