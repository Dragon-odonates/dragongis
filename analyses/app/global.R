suppressPackageStartupMessages({
  require(shiny)
  require(shinycssloaders)
  require(tmap)
  require(terra)
  # require(viridis)
  # require(leaflet)
})

if(Sys.getenv('SHINY_PORT') == "") {options(shiny.maxRequestSize=10000*1024^2)}

folder <- ifelse(Sys.getenv('SHINY_PORT') == "", here::here("analyses", "app", "data"), "data")

# interactive mode for tmap
suppressMessages(tmap_mode("view"))

# load gis data
sp <- readRDS(here::here(folder, "sp10000.rds"))
po <- readRDS(here::here(folder, "po10000.rds"))
py <- readRDS(here::here(folder, "py10000.rds"))

