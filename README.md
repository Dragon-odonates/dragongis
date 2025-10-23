# dragongis
Spatial exploration of odonates database


## General

This repository is structured as follow:

- :file_folder: &nbsp;`analyses/`: contains R scripts to prepare the dataset and make the analysis;
- :file_folder: &nbsp;`data/`: contains raw and derived data;


## Usage

The analysis is divided in two pipeline of four steps each : (A) data cleaning and exploration, and (B) extraction of environmental data.

A. There are 4 sequential steps ():  

1. extract data from the local database
2. clean and transform the occurrence data, create a grid  
3. compute statistics per grid cell (e.g. species richness)  
4. make [exploration dashboard](https://dragon-odonates.github.io/dragongis/)  

```r
source("make.R")
```

B. There are 4 sequential steps:  

1. transform the occurrence data in a 50km grid  
2. extract landcover information on the 50km grid (Corine)
3. extract bioclimatic variables on the 50km grid (CHELSA)
4. format environmental data 

```r
source("make_B.R")
```


**Be aware**:
- The dataset is heavy and not hosted in Github.   
- The analysis takes around 10 min to run on a normal laptop.    

