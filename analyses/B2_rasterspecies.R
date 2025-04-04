# load spatial packages
library(terra)
library(sf)
# set the function to calculate the number of unique elements
nodup <- function(x) {return(sum(!duplicated(x)))}

res_grid <- 10000

df <- readRDS(here::here("data", "derived-data", "occ_all_df.rds"))
grid10 <- readRDS(here::here("data", "derived-data", paste0("grid_", res_grid,".rds")))



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
# yearobs_grid <- tapply(df$observationID, list(df$Year, df$gridfac), nodup)
# year5_grid <- apply(yearobs_grid>5, 2, sum, na.rm=TRUE)
# year5_grid[is.na(year_grid)] <- NA

# set into the grid
nspe <- setValues(grid10, as.numeric(spe_grid))
names(nspe) <- "nspe"
nobs <- setValues(grid10, as.numeric(obs_grid))
names(nobs) <- "nobs"
nyr <- setValues(grid10, as.numeric(year_grid))
names(nyr) <- "nyr"
# nyr5 <- setValues(grid10, as.numeric(year5_grid))
# names(nyr5) <- "nyr5"

# merge into a single raster file
statrast <- c(nspe, nobs, nyr)#, nyr5)
# export the raster
saveRDS(statrast, here::here("data", "derived-data", paste0("stat_", res_grid,".rds")))


## calculate species observation per grid cell
n <- table(df$species)
ngrid <- table(df$gridfac)
nrast <- nspe
prast <- nobs
yrast <- nyr
for (s in names(n)[n>50000]){
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

# system.time({source("analyses/B2_rasterspecies.R")})
# 1 min, 8gb (without year5)

# for the shiny app
# sp <- project(nrast, crs("EPSG:3857"))
# names(sp)[1] <- "All"
# po <- project(prast, crs("EPSG:3857"))
# names(po)[1] <- "All"
# py <- project(yrast, crs("EPSG:3857"))
# names(py)[1] <- "All"
# saveRDS(sp, here::here("analyses", "app", "data", "sp10000.rds"), compress="xz")
# saveRDS(po, here::here("analyses", "app", "data", "po10000.rds"), compress="xz")
# saveRDS(py, here::here("analyses", "app", "data", "py10000.rds"), compress="xz")