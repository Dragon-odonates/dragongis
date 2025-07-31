# dragongis
Spatial exploration of odonates database


## General

This repository is structured as follow:

- :file_folder: &nbsp;`analyses/`: contains R scripts to prepare the dataset and make the analysis;
- :file_folder: &nbsp;`data/`: contains raw and derived data;

## Usage

The analysis is divided in three sequential steps (each step has a dedicated R file):  

1. extract data from the local database
2. clean and transform the occurrence data, create a grid  
3. compute statistics per grid cell (e.g. species richness)  
4. make exploration dashboard  
5. prepare data for the species-specific Shiny app

**Be aware**:
- The dataset is heavy and not hosted in Github.   
- The analysis takes around 10 min to run on a normal laptop.    


These steps (except 3bis) will be run automatically with the R command: 

```r
source("make.R")
```

## To do list:

1. add other GIS information