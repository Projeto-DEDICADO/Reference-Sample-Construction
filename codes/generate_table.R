# setwd("/home/jovyan/dedicado_Amostras/03_Scripts")

library(sf)
library(mapview)
library(tidyterra)
library(tidyverse)

deter_grid <- st_read("~/dedicado_Amostras/02_Data/tiling/deter_regions.shp")
crs_deter <- st_crs(deter_grid)

#### RADD ####
RADD <- read_sf("~/dedicado_Amostras/01_Pre_processing/GLAD_RADD/05_outputs/RADD_atualizado_2/RADD.shp")
# RADD <- st_transform(RADD, crs_deter) |> st_cast("POLYGON")

write_sf(RADD, "RADD.shp")

#### GLAD ####
GLAD <- read_sf("~/dedicado_Amostras/01_Pre_processing/GLAD_RADD/05_outputs/GLAD_atualizado/GLAD.shp")
GLAD <- st_transform(GLAD, crs_deter)

GLAD$year[GLAD$year == 1]  <- "Before 2020"
GLAD$year[GLAD$year == 20] <- "2020"
GLAD$year[GLAD$year == 21] <- "2021"
GLAD$year[GLAD$year == 22] <- "2022"
GLAD$year[GLAD$year == 23] <- "2023"
GLAD$year[GLAD$year == 24] <- "2024"

write_sf(GLAD, "GLAD.shp")

#### DETER ####
DETER <- read_sf("~/dedicado_Amostras/01_Pre_processing/PRODES_DETER/03_outputs/DETER_atualizado/Deter.shp")

write_sf(DETER, "DETER.shp")

#### DETER Before ####
DETER_Before <- read_sf("~/dedicado_Amostras/01_Pre_processing/PRODES_DETER/03_outputs/DETER_atualizado/Deter_before.shp")

write_sf(DETER_Before, "DETER_Before.shp")

#### PRODES ####
# PRODES <- read_sf("~/dedicado_Amostras/01_Pre_processing/PRODES_DETER/03_outputs/PRODES.shp")
PRODES <- read_sf("~/dedicado_Amostras/01_Pre_processing/PRODES_DETER/03_outputs/PRODES/Prodes.shp")
# PRODES <- st_transform(PRODES, crs_deter) |> st_cast("POLYGON")

write_sf(PRODES, "PRODES.shp")

#### PRODES Before ####
PRODES_Before <- read_sf("~/dedicado_Amostras/01_Pre_processing/PRODES_DETER/03_outputs/PRODES/Prodes_before.shp")

write_sf(PRODES_Before, "PRODES_Before.shp")

#### MapBiomas ####
MapBiomas <- read_sf("~/dedicado_Amostras/01_Pre_processing/MapBiomas/MapBiomas/MapBiomas.shp")
MapBiomas <- st_transform(MapBiomas, crs_deter) |> st_cast("POLYGON")
names(MapBiomas)[7] <- "year"
MapBiomas$year[MapBiomas$year == 2019]  <- "Before 2020"

write_sf(MapBiomas, "MapBiomas.shp")

#### TropiSCO ####
TropiSCO <- read_sf("~/dedicado_Amostras/01_Pre_processing/TropiSCO/TropiSCO/tropisco.shp")
# TropiSCO <- st_transform(TropiSCO, crs_deter) |> st_cast("POLYGON")

write_sf(TropiSCO, "TropiSCO.shp")

#### SAD ####
SAD <- read_sf("~/dedicado_Amostras/01_Pre_processing/SAD/SAD_atualizado/SAD.shp")
# SAD <- st_transform(SAD, crs_deter) |> st_cast("POLYGON")
# names(SAD)[3] <- "year"

write_sf(SAD, "SAD.shp")

#### BDC ####

BDC_tiles_L <- st_read("~/dedicado_Amostras/02_Data/BDC_LG/BDC_LG_V2.shp")
BDC_tiles_L <- st_transform(BDC_tiles_L, crs_deter)

#### Load Alerts ####

RADD <- read_sf("RADD.shp")
GLAD <- read_sf("GLAD.shp")
DETER <- read_sf("DETER.shp")
DETER_Before <- read_sf("DETER_Before.shp")
PRODES <- read_sf("PRODES.shp")
PRODES_Before <- read_sf("PRODES_Before.shp")
MapBiomas <- read_sf("MapBiomas.shp")
TropiSCO <- read_sf("TropiSCO.shp")
SAD <- read_sf("SAD.shp")

#### Loop for ####
# tiles_table <- tibble()
# tiles_table <- read_csv("tabela.csv")

for (i in 432:length(deter_grid$id)) {
  tempo <- system.time({

  RADD_tile          <- st_intersection(deter_grid[i,], RADD)
  GLAD_tile          <- st_intersection(deter_grid[i,], GLAD)
  DETER_tile         <- st_intersection(deter_grid[i,], DETER)
  DETER_Before_tile  <- st_intersection(deter_grid[i,], DETER_Before)
  PRODES_tile        <- st_intersection(deter_grid[i,], PRODES)
  PRODES_Before_tile <- st_intersection(deter_grid[i,], PRODES_Before)
  tropisco_tile      <- st_intersection(deter_grid[i,], TropiSCO)
  MapBiomas_tile     <- st_intersection(deter_grid[i,], MapBiomas)
  SAD_tile           <- st_intersection(deter_grid[i,], SAD)

  tiles_table_line <- tibble(
    "DETER_grd"          = deter_grid[i,1][[1]],
    "area_DETER"         = sum(st_area(DETER_tile)),
    "area_PRODES"        = sum(st_area(PRODES_tile)),
    "area_MapBiomas"     = sum(st_area(MapBiomas_tile)),
    "area_GLAD"          = sum(st_area(GLAD_tile)),
    "area_RADD"          = sum(st_area(RADD_tile)),
    "area_TropiSCO"      = sum(st_area(tropisco_tile)),
    "area_SAD"           = sum(st_area(SAD_tile)),
    "area_PRODES_Before" = sum(st_area(PRODES_Before_tile)),
    "area_DETER_Before" = sum(st_area(DETER_Before_tile)),

    "area_outros" = sum(st_area(st_union(rbind(
      GLAD_tile["year"],
      RADD_tile["year"],
      tropisco_tile["year"],
      SAD_tile["year"]
      )))),

    "area_SAR" = sum(st_area(st_union(rbind(
      RADD_tile["year"],
      tropisco_tile["year"]
      )))),

    "area_optico" = sum(st_area(st_union(rbind(
      DETER_tile["year"],
      GLAD_tile["year"]
      )))),

    "area_Total" = sum(st_area(st_union(rbind(
      DETER_tile["year"],
      PRODES_tile["year"],
      MapBiomas_tile["year"],
      GLAD_tile["year"],
      RADD_tile["year"],
      tropisco_tile["year"],
      SAD_tile["year"]
      )))),

    "area_intersec" = sum(st_area(st_intersection(st_union(DETER_tile["year"]),
                                                  st_union(rbind(GLAD_tile["year"],
                                                                 RADD_tile["year"],
                                                                 tropisco_tile["year"],
                                                                 SAD_tile["year"]
                                                                 ))))),

    "area_dif" = sum(st_area(st_difference(st_union(DETER_tile),
                                           st_union(rbind(GLAD_tile["year"],
                                                          RADD_tile["year"],
                                                          tropisco_tile["year"],
                                                          SAD_tile["year"]
                                                          ))))),

    "area_difSAR" = sum(st_area(st_difference(st_union(DETER_tile),
                                              st_union(rbind(RADD_tile["year"],
                                                             tropisco_tile["year"]
                                                             )) ))),

    "area_2020" = sum(st_area(filter(DETER_tile, year == 2020))),
    "area_2021" = sum(st_area(filter(DETER_tile, year == 2021))),
    "area_2023" = sum(st_area(filter(DETER_tile, year == 2023))),
    "area_2022" = sum(st_area(filter(DETER_tile, year == 2022))),
    "area_2024" = sum(st_area(filter(DETER_tile, year == 2024))),

    "area_1CzQ" = sum(st_area(filter(DETER_tile, CLASSNAME == "CICATRIZ_DE_QUEIMADA"))),
    "area_2CsD" = sum(st_area(filter(DETER_tile, CLASSNAME == "CS_DESORDENADO"))),
    "area_3CsG" = sum(st_area(filter(DETER_tile, CLASSNAME == "CS_GEOMETRICO"))),
    "area_4Deg" = sum(st_area(filter(DETER_tile, CLASSNAME == "DEGRADACAO"))),
    "area_5CrS" = sum(st_area(filter(DETER_tile, CLASSNAME == "DESMATAMENTO_CR"))),
    "area_6CrV" = sum(st_area(filter(DETER_tile, CLASSNAME == "DESMATAMENTO_VEG"))),
    "area_7Min" = sum(st_area(filter(DETER_tile, CLASSNAME == "MINERACAO"))),

    "area_PRes" = sum(st_area(filter(PRODES_tile, sub_class == "reservatorio"))),
    "area_PInu" = sum(st_area(filter(PRODES_tile, sub_class == "floresta inundada"))),
    "area_PDPr" = sum(st_area(filter(PRODES_tile, sub_class == "desmatamento por degradação progressiva"))),
    "area_PCrS" = sum(st_area(filter(PRODES_tile, sub_class == "corte raso com solo exposto"))),
    "area_PCrV" = sum(st_area(filter(PRODES_tile, sub_class == "corte raso com vegetação"))),
    "area_PMin" = sum(st_area(filter(PRODES_tile, sub_class == "mineração"))),

    "area_BAgr" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "agriculture"))),
    "area_BRes" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "reservoir_or_dam"))),
    "area_BOut" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "others"))),
    "area_BEne" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "renewable_energy_project"))),
    "area_BAqu" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "aquaculture"))),
    "area_BRua" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "roads"))),
    "area_BUrb" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "urban_expansion"))),
    "area_BNat" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "natural_cause"))),
    "area_BIMi" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "ilegal_mining"))),
    "area_BMin" = sum(st_area(filter(MapBiomas_tile, VPRESSAO == "mining"))),

    "area_Degrad" = sum(st_area(filter(SAD_tile, alerta == "degradacao"))),
    "area_Desmat" = sum(st_area(filter(SAD_tile, alerta == "desmatamento")))

    )

  tiles_table <- rbind(tiles_table, tiles_table_line)
  write_csv(tiles_table, "tabela.csv")
  })
  
  cat("Iteracao", i, "- Tempo:", tempo["elapsed"], "segundos\n")
}


