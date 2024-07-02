library(sf)
library(dplyr)
library(mapview)

# load("data/admin_express.RData")

chemin <- "C:/Users/Dr Constance SEBBAN/Downloads"

#Liste de tous les bureaux de vote français
bv <- readr::read_csv(paste0(chemin,"/table-bv-reu.csv"))

#liste des bureaux de vote bordelais
bv_bordeaux <- bv %>% 
  filter(code_commune == "33063")

# liste de toutes les adresses
adresses <- readr::read_csv(paste0(chemin,"/table-adresses-reu.csv"))
#transfo en fichier
adresses_geo <- st_as_sf(adresses,coords = c("longitude","latitude")) %>% st_set_crs(4326)
adresses_geo_bordeaux <- adresses_geo %>% filter(code_commune_ref == "33063")
adresses_geo_bordeaux <- adresses_geo_bordeaux %>% rename(id_brut_reu =id_brut_bv_reu)


adresses_bv_geo_bordeaux <- adresses_geo_bordeaux %>% left_join(bv_bordeaux,by="id_brut_reu")



#Carte avec toutes les adresses par bureau de vote à Bordeaux
mapview(adresses_bv_geo_bordeaux,zcol = "voie_reu",legend=TRUE)

