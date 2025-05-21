# Prepare data for the Shiny app


# Libraries ---------------------------------------------------------------
library(here)


funcdir <- here("functions")
source(here(funcdir, "functions.R"))

res_grid <- 10000

# Read data ---------------------------------------------------------------
df <- readRDS(here::here("data", "derived-data", "occ_all_df.rds"))

statrast <- readRDS(here("data", "derived-data", 
                         paste0("stat_", res_grid, ".rds")))
grid10 <- readRDS(here::here("data", "derived-data", 
                             paste0("grid_", res_grid,".rds")))

# Transform data ----------------------------------------------------------


## Transform table ---------------------------------------------------------
mini <- df[, c("species", "dbID", "Year", 
               "grid10kmID", "observationID", "Country")]
mini <- mini[!duplicated(mini),]

## Compute spatial statistics by species -----------------------------
ngrid <- table(df$grid10kmID)

# Number of observation per cell
obs_grid <- statrast[["nobs"]]
nobs <- values(obs_grid)[, 1]
# Number of year per cell
year_grid <- statrast[["nyr"]]
nyr <- values(statrast)[, 1]
# Number of species per cell
spe_grid <- statrast[["nspe"]]
nspe <- values(spe_grid)[, 1]

# Get species total counts
n <- table(df$species)

for (s in names(n)){ # [n > 50000]){
  # Get the subset of observations for this species
  ms <- df$species == s
  
  # Number of obs of species s per grid cell
  n_grid <- table(df$grid10kmID[ms])
  n_grid[is.na(nobs)] <- NA
  # Add to raster
  ns <- setValues(grid10, as.numeric(nobs))
  
  # Percentage obs of species s contained in each grid cell
  p_grid <- tapply(df$observationID[ms], df$grid10kmID[ms], nodup)/nobs*100
  p_grid[is.na(nobs)] <- NA # Set percentage to zero of there were no obs of this species
  # in sampled grid
  p_grid[!is.na(nobs) & is.na(p_grid)] <- 0
  # Add to raster
  ps <- setValues(grid10, as.numeric(p_grid))
  
  # Percentage of years where s was observed in each grid cell
  y_grid <- tapply(df$Year[ms], df$grid10kmID[ms], nodup)/nyr*100
  y_grid[is.na(nobs)] <- NA
  y_grid[!is.na(nobs)&is.na(y_grid)] <- 0
  # Add to raster
  ys <- setValues(grid10, as.numeric(y_grid))
  
  # Add species raster to global raster
  spe_grid <- c(spe_grid, ns)
  names(spe_grid)[nlyr(spe_grid)] <- s
  
  obs_grid <- c(obs_grid, ps)
  names(obs_grid)[nlyr(obs_grid)] <- s
  
  year_grid <- c(year_grid, ys)
  names(year_grid)[nlyr(year_grid)] <- s
}

# Reproject
spe_grid <- project(spe_grid, crs("EPSG:3857"))
names(spe_grid)[1] <- "All"

obs_grid <- project(obs_grid, crs("EPSG:3857"))
names(obs_grid)[1] <- "All"

year_grid <- project(year_grid, crs("EPSG:3857"))
names(year_grid)[1] <- "All"


# Export to app -----------------------------------------------------------
saveRDS(mini, here::here("analyses", "app", "data", "occ_mini.rds"))

saveRDS(spe_grid, 
        here::here("analyses", "app", "data", "sp10000.rds"), compress="xz")
saveRDS(obs_grid, 
        here::here("analyses", "app", "data", "po10000.rds"), compress="xz")
saveRDS(year_grid, 
        here::here("analyses", "app", "data", "py10000.rds"), compress="xz")
