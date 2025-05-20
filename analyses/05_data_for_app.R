# Prepare data for the Shiny app


# Libraries ---------------------------------------------------------------
library(here)


# Read data ---------------------------------------------------------------
df <- readRDS(here::here("data", "derived-data", "occ_all_df.rds"))

# Transform data ----------------------------------------------------------


## Transform table ---------------------------------------------------------
mini <- df[, c("species", "dbID", "Year", 
               "grid10kmID", "observationID", "Country")]
mini <- mini[!duplicated(mini),]

## Compute spatial statistics by species -----------------------------
n <- table(df$species)
ngrid <- table(df$gridfac)
nrast <- nspe
prast <- nobs
yrast <- nyr
for (s in names(n)[n>50000]){
  ms <- df$species == s
  # percentage obs per grid cell
  n_grid <- table(df$gridfac[ms])
  n_grid[is.na(obs_grid)] <- NA
  ns <- setValues(grid10, as.numeric(n_grid))
  
  # percentage obs per grid cell
  p_grid <- tapply(df$observationID[ms], df$gridfac[ms], nodup)/obs_grid*100
  p_grid[is.na(obs_grid)] <- NA
  p_grid[!is.na(obs_grid)&is.na(p_grid)] <- 0
  ps <- setValues(grid10, as.numeric(p_grid))
  
  # percentage year per grid cell
  y_grid <- tapply(df$Year[ms], df$gridfac[ms], nodup)/year_grid*100
  y_grid[is.na(obs_grid)] <- NA
  y_grid[!is.na(obs_grid)&is.na(y_grid)] <- 0
  ys <- setValues(grid10, as.numeric(y_grid))
  
  nrast <- c(nrast, ns)
  names(nrast)[nlyr(nrast)] <- s
  prast <- c(prast, ps)
  
  names(prast)[nlyr(prast)] <- s
  yrast <- c(yrast, ys)
  names(yrast)[nlyr(yrast)] <- s
}

# Reproject
sp <- project(nrast, crs("EPSG:3857"))
names(sp)[1] <- "All"
po <- project(prast, crs("EPSG:3857"))
names(po)[1] <- "All"
py <- project(yrast, crs("EPSG:3857"))
names(py)[1] <- "All"


# Export to app -----------------------------------------------------------
saveRDS(mini, here::here("analyses", "app", "data", "occ_mini.rds"))

saveRDS(sp, 
        here::here("analyses", "app", "data", "sp10000.rds"), compress="xz")
saveRDS(po, 
        here::here("analyses", "app", "data", "po10000.rds"), compress="xz")
saveRDS(py, 
        here::here("analyses", "app", "data", "py10000.rds"), compress="xz")
