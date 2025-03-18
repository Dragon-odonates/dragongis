# Load the raw data of observations
# create a grid with terra over the extant of the observation
# save the grids in grid_data.Rdata 
# run in 2 min, 10gb memory
# system.time({source("analyses/create_grid.R")})

library(sf)
library(terra)

tab <- readRDS(here::here("data", "raw-data", "occ_all_sf.rds"))
dim(tab) #6468361      10
# class(tab)

# to make it simpler, use only the centroid for linestrings and POLYGON
tab <- st_centroid(tab)

# might be faster to transform in data.frame
# df <- st_set_geometry(tab, NULL)

coo <- st_coordinates(tab$decimalCoordinates)

# create a unique ID for each observation event
# the ID is made of the data, dataset and observer ID
# and the coordinates at 100 x 100m rounded
tab$ID <- paste(tab$eventDate, tab$datasetID, tab$recorderID, round(coo[,1]/100), round(coo[,2]/100), sep="_")
# lunique <- function(x){return(length(unique(x)))}
# system.time({print(lunique(tab$ID))})
nodup <- function(x){return(sum(!duplicated(x)))}
system.time({print(nodup(tab$ID))}) # 2769644

tab$Year <- substr(tab$eventDate, 1, 4)
table(tab$Year)

# select only observation between 1950 and 2024
# AND with valid geometry
keep <- !st_is_empty(tab$decimalCoordinates) & tab$Year %in% 1950:2024
# dplyr is twice faster than: tab <- tab[keep,,drop=FALSE]
tab <- dplyr::filter(tab, keep)


# get the grid (just to get the crs)
grid_10000 <- readRDS(here::here("data", "raw-data", "grid_scale_10000.rds"))

# create the sf geomtry object
vobs <- st_sf(tab[,c("ID","Year", "species")],  crs = crs(grid_10000))
# way too slow ...
# vobs <- terra::vect(st_sfc(tab$decimalCoordinates, crs = crs(grid_10000)),
#                     atts=tab[,c("ID","Year", "species")])

# but terra is powerfull at making grid
# st_make_grid(vobs, cellsize = 1000, what = "centers")

grid1km <- rast(ext(st_bbox(vobs)), res=1000, crs = crs(grid_10000))
grid5km <- rast(ext(st_bbox(vobs)), res=5000, crs = crs(grid_10000))
grid10km <- rast(ext(st_bbox(vobs)), res=10000, crs = crs(grid_10000))

saveRDS(grid1km, here::here("data", "derived-data", "grid_1km.rds"))
saveRDS(grid5km, here::here("data", "derived-data", "grid_5km.rds"))
saveRDS(grid10km, here::here("data", "derived-data", "grid_10km.rds"))
saveRDS(vobs, here::here("data", "derived-data", "vect_obs.rds"))

# never save as Rdata file => it makes errors with terra package
# save(vobs, grid1km, grid5km, grid10km,
#      file= here::here("data", "derived-data", "grid_data.Rdata"), 
#      compress= "xz")
