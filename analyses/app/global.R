suppressPackageStartupMessages({
  require(shiny)
  require(shinycssloaders)
  require(tmap)
  require(terra)
  require(plotly)
  require(collapse)
  require(RColorBrewer)
  require(here)
})

funcdir <- here("functions")
source(here(funcdir, "functions.R"))

if(Sys.getenv('SHINY_PORT') == "") {options(shiny.maxRequestSize=10000*1024^2)}

folder <- ifelse(Sys.getenv('SHINY_PORT') == "", here::here("analyses", "app", "data"), "data")

# interactive mode for tmap
suppressMessages(tmap_mode("view"))

# load gis data
sp <- readRDS(here::here(folder, "sp10000.rds"))
po <- readRDS(here::here(folder, "po10000.rds"))
py <- readRDS(here::here(folder, "py10000.rds"))

dt <- readRDS(here::here(folder, "occ_mini.rds"))

# Get colors for datasets
dsets <- sort(funique(dt$dbID))
ndat <- length(dsets)

dataset_color <- colorRampPalette(brewer.pal(8, "Dark2"))(ndat)
names(dataset_color) <- dsets

# Get colors for countries
countries <- sort(funique(dt$Country))
ncountries <- length(countries)

countries_color <- colorRampPalette(brewer.pal(8, "Dark2"))(ncountries)
names(countries_color) <- countries