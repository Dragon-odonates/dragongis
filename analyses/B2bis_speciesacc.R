long <- readRDS(here::here("analyses", "app", "data", "occ_mini.rds"))

# with vegan, super long ... 
# because it calculates from 1 to the number of sites ...
# wide <- table(long$observationID, long$species)
# # let's make exact estimation first (random would be prefered)
# system.time({
#   sa_all <- vegan::specaccum(wide) #, method="random") 
# })


# set the function to calculate the number of unique elements
lunique <- function(x) {return(sum(!duplicated(x)))}

# set the function to calculate species accumulation curves
# from long format dataset
# taxa : species name
# sites: site
# nseq : sequence of number of site selections
# rep: number of repetations per number of site selection
# probs: probability in quantile out of the calculated repetitions
# n_cores: number of cores

spe_acc_lapply <- function(taxa, site, nseq = 2:min(c(100,lunique(site)/2)), nrep = 100, probs = c(0.25,0.5, 0.75)){
  out <- c()
  usite <- unique(site)
  if (max(nseq)>length(usite)){
    stop("Number of sites lower than max(nseq).")
  }
  out <- lapply(nseq, function(i) {
    ni <- sapply(1:nrep, function(x) lunique(taxa[site%in%sample(usite, i, replace=FALSE)]))
    return(quantile(ni, probs = probs)) 
  })
  out <- data.frame(t(sapply(out,c)))
  names(out) <- paste0("Q",probs)
  row.names(out) <- nseq
  return(out)
}

spe_acc_mclapply <- function(taxa, site, nseq = 2:min(c(100,lunique(site)/2)), nrep = 100, probs = c(0.25,0.5, 0.75), n_cores=1){
  out <- c()
  usite <- unique(site)
  if (max(nseq)>length(usite)){
    stop("Number of sites lower than max(nseq).")
  }
  out <- parallel::mclapply(nseq, function(i) {
    ni <- sapply(1:nrep, function(x) lunique(taxa[site%in%sample(usite, i, replace=FALSE)]))
    return(quantile(ni, probs = probs)) 
  }, mc.cores = n_cores)
  out <- data.frame(t(sapply(out,c)))
  names(out) <- paste0("Q",probs)
  row.names(out) <- nseq
  return(out)
}


# compute for all
system.time({sa_all <- spe_acc_mclapply(long$species, long$observationID, nrep=50, n_cores=8)})
#582.589 sec, nrep=50

sa_db <- list()
for (i in sort(unique(long$"dbID"))){
  print(i)
  subi <- long[long$dbID%in%i,]
  if (lunique(subi$observationID)>10000){
    sa_db[[i]] <- spe_acc_mclapply(subi$species, subi$observationID, nrep=50, n_cores=8)
  }
}
# export to avaid re-calculating
save(sa_all, sa_db, file = "data/derived-data/speacc_50.Rdata")


# base plot
seqx <- 2:100
plot(seqx, sa_all$Q0.5, type="l", lwd=4, ylim=c(2, 60))
lapply(seq_along(sa_db), function(i) lines(seqx, sa_db[[i]]$Q0.5, col=rainbow(11)[i]))
legend("bottomright", col = rainbow(11), lwd=1, legend= names(sa_db), ncol=3, cex=0.5)

# smoothed
lo <- loess(sa_all$Q0.5 ~ seqx)
plot(seqx, predict(lo), ylim=c(2, 60), type="l", lwd=4)
lapply(seq_along(sa_db), function(i) {
  li <- loess(sa_db[[i]]$Q0.5 ~ seqx)
  lines(seqx, predict(li), col=rainbow(11)[i])
})
legend("bottomright", col = rainbow(11), lwd=1, legend= names(sa_db), ncol=3)

# in plotly
library(plotly)
fig <- plot_ly(x = seqx) 
fig <- fig %>% add_lines(y = predict(lo), name = "all", line = list(color = 'rgb(0, 0, 0)', width = 2)) 
for (i in seq_along(sa_db)){
  li <- loess(sa_db[[i]]$Q0.5 ~ seqx)
  fig <- fig %>% add_lines(y = predict(li), name = names(sa_db)[i]) 
}
fig %>% layout(title = "Species accumulation curves", 
              xaxis = list(title = "Number of observations"),
              yaxis = list(title = "Number of species"))
