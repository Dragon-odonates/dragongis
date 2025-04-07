long <- readRDS(here::here("analyses", "app", "data", "occ_mini.rds"))

wide <- table(long$observationID, long$species)

# let's make exact estimation first (random would be prefered)
system.time({
  sa_all <- vegan::specaccum(wide) #, method="random") 
})

plot(sa_all)

sa_db <- list()
for (i in sort(unique(long$"dbID"))){
  obsi <- unique(long$observationID[long$dbID%in%i])
  sa_db[[i]] <- vegan::specaccum(wide, subset = row.names(wide)%in%obsi)
}
  