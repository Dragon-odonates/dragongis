# Format the environmental data
# avoid repeating B2 and B3 for formating issues
# input:
#  derived-data/Bioclim_50km.csv
#  derived-data/CLC2018_50km.csv
# output:
#  derived-data/Envdata_50km.csv

# format and aggregate CLC data
clc_50k <- read.csv(here("data", "derived-data", "CLC2018_50km.csv"))
# see the classes and labels from the original data
# clc <- rast(here("data", "raw-data", "U2018_CLC2018_V2020_20u1.tif"))
# levels(clc$LABEL3)[[1]]
agg_class <- list(
  "artificial" = 1:11,
  "agriculture" = 12:22,
  "forest" = 23:25,
  "shrub" = 26:29,
  "open" = 30:34,
  "marshes" = 35,
  "peat bogs" = 36,
  "coastal wetland" = 37:39,
  "rivers" = 40,
  "lakes" = 41,
  "marine waters" = 42:44
)

# tot <- rowSums(clc_50k[, grep("frac", names(clc_50k))], na.rm = TRUE)
# table(tot>0) # only two cells without data

new_clc <- data.frame("cellcode" = clc_50k$cellcode)

for (i in seq_along(agg_class)) {
  labi <- paste0("frac_", agg_class[[i]])
  if (length(labi) > 1) {
    sumi <- rowSums(clc_50k[, labi]) * 100
  } else {
    sumi <- clc_50k[, labi] * 100
  }
  new_clc <- cbind(new_clc, sumi)
}
colnames(new_clc)[-1] <- paste0("clc_", names(agg_class))

bio_50k <- read.csv(here("data", "derived-data", "Bioclim_50km.csv"))
names(bio_50k) <- gsub("^bio1$", "bio1_annual_temp_dC", names(bio_50k))
names(bio_50k) <- gsub("^bio10$", "bio10_temp_warmQ_dC", names(bio_50k))
names(bio_50k) <- gsub("^bio12$", "bio12_annual_prec_mm", names(bio_50k))
names(bio_50k) <- gsub("^bio15$", "bio15_coefvar_prec", names(bio_50k))
names(bio_50k) <- gsub("^bio4$", "bio4_sd_temp", names(bio_50k))


# table(new_clc$cellcode == bio_50k$cellcode)
out <- cbind(new_clc, bio_50k[, -1])

write.csv(
  out,
  here("data", "derived-data", "Envdata_50km.csv"),
  row.names = FALSE
)
summary(out)
