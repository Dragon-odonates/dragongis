# Extract data from database
# This script works only on the computer hosting the Dragon database
  

# Libraries etc -----------------------------------------------------------
library(here)
library(data.table)
library(RPostgres)
library(sf)

out_folder <- here("data/raw-data")


# Query DB ----------------------------------------------------------------

# Connect to "local" DB
con <- dbConnect(
  drv       = RPostgres::Postgres(),
  dbname    = "dragon",
  host      = "localhost",
  port      = 5432,
  user      = Sys.getenv('USERNAME'),
  password  = Sys.getenv('PASSWORD')
)

occ_all <- dbGetQuery(con, 'SELECT "scientificName", "taxonRank",
                        "species", "genus", "family",
                        "decimalLatitude", "decimalLongitude", "country",
                        "eventDate", d."datasetID", d."datasetName", 
                        d."parentDatasetID", 
                        dpar."datasetName" AS "parentDatasetName",
                        "occurrenceStatus", "individualCount", "Event"."recorderID"
                        FROM "Taxon"
                        LEFT JOIN "Occurrence"
                            ON "Taxon"."taxonID" = "Occurrence"."taxonID"
                        LEFT JOIN "Event"
                            ON "Event"."eventID" = "Occurrence"."eventID"
                        LEFT JOIN "Dataset" AS d
                            ON "Event"."datasetID" = d."datasetID"
                        LEFT JOIN "Dataset" AS dpar
                            ON d."parentDatasetID" = dpar."datasetID"
                        LEFT JOIN "EventDate"
                            ON "Event"."eventDateID" = "EventDate"."eventDateID"
                        LEFT JOIN "Location"
                            ON "Location"."locationID" = "Event"."locationID" 
                            AND "Location"."datasetID" = d."datasetID"
                        LEFT JOIN "Recorder"
                            ON "Recorder"."recorderID" = "Event"."recorderID" 
                            AND "Recorder"."datasetID" = d."datasetID"
                        WHERE "decimalLatitude" IS NOT NULL 
                            AND "decimalLongitude" IS NOT NULL 
                            AND ("occurrenceStatus" = \'present\' 
                                OR "occurrenceStatus" IS NULL);')

dbDisconnect(con)


# Format output -----------------------------------------------------------

# Transform to sf
occ_all_sf <- st_as_sf(occ_all, 
                       coords = c( "decimalLongitude", "decimalLatitude"),
                       na.fail = FALSE)
rm(occ_all)

st_crs(occ_all_sf) <- 4326

# Transform coordinates
occ_all_sf <- st_transform(occ_all_sf, 3035)

saveRDS(occ_all_sf,
        file.path(out_folder, "occ_all_sf.rds"))

# Save subdataset
occ_sub_sf <- occ_all_sf[sample(1:nrow(occ_all_sf),
                                size = 1000000,
                                replace = FALSE), ]
saveRDS(occ_sub_sf,
        file.path(out_folder, "occ_sub_sf.rds"))

# Save data.table
geom <- st_coordinates(occ_all_sf)
occ_all <- data.table(st_drop_geometry(occ_all_sf))
rm(occ_all_sf)
occ_all[, `:=`(decimalLongitude = geom[, 1],
               decimalLatitude = geom[, 2])]
saveRDS(occ_all,
        file.path(out_folder, "occ_all.rds"))
rm(occ_all)

# Save sub data.table
geom <- st_coordinates(occ_sub_sf)
occ_sub <- data.table(st_drop_geometry(occ_sub_sf))
rm(occ_sub_sf)
occ_sub[, `:=`(decimalLongitude = geom[, 1],
               decimalLatitude = geom[, 2])]
saveRDS(occ_sub,
        file.path(out_folder, "occ_sub.rds"))
