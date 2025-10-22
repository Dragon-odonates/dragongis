# Extract data from database
# This script works only on the computer hosting the Dragon database
# input:
#  raw-data/EEA_50km.gpkg
#  raw-data/U2018_CLC2018_V2020_20u1.tif

# CHELSA
# Karger, D.N., Conrad, O., Böhner, J., Kawohl, T., Kreft, H., Soria-Auza, R.W., Zimmermann, N.E., Linder, P., Kessler, M. (2017).
# Climatologies at high resolution for the Earth land surface areas. Scientific Data. 4 170122. https://doi.org/10.1038/sdata.2017.122
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio10_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio12_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio4_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio1_1981-2010_V.2.1.tif
# https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio15_1981-2010_V.2.1.tif
# Or
# WORLDCLIM
# Fick, S.E. and R.J. Hijmans, 2017.
# WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315
# https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_bio.zip

devtools::load_all()

# Load the EEA 50km grid with terra
grid <- vect(here("data", "derived-data", "EU_grid_50km.gpkg"))
# transform to lat/long WGS84
grid_4326 <- project(grid, "EPSG:4326")

# Load the bioclimatic data
chelsa_files <- list.files(
  "data",
  "^CHELSA_",
  recursive = TRUE,
  full.names = TRUE
)

bio <- rast(chelsa_files)

# make the extraction with terra
bio_50k <- extract(bio, grid, fun = mean, na.rm = TRUE)
bio_50k$ID <- grid$cellcode
lab <- sapply(strsplit(chelsa_files, "_"), function(x) x[[2]])
names(bio_50k) <- c("cellcode", lab)

# save full extraction (to avoid repeting the previous step)
write.csv(
  bio_50k,
  here("data", "derived-data", "Bioclim_50km.csv"),
  row.names = FALSE
)
