library(sf)
library(dplyr)
library(mapview)
library(recipes)
library(janitor)
library(ggplot2)

# load("data/admin_express.RData")

chemin <- "C:/Users/Dr Constance SEBBAN/Downloads"
ville <- "33063" #Bordeaux

#Liste de tous les bureaux de vote français
bv <- readr::read_csv(paste0(chemin,"/table-bv-reu.csv"))

#liste des bureaux de vote bordelais
bv_bordeaux <- bv %>% 
  filter(code_commune == ville)


# liste de toutes les adresses
adresses <- readr::read_csv(paste0(chemin,"/table-adresses-reu.csv"))
#transfo en format vecteur
adresses_geo <- st_as_sf(adresses,coords = c("longitude","latitude")) %>% st_set_crs(4326)
adresses_geo_bordeaux <- adresses_geo %>% filter(code_commune_ref == ville) %>% 
  rename(id_brut_reu =id_brut_bv_reu)

#jointure entre les adresses des logements et les bureaux de vote
adresses_bv_geo_bordeaux <- adresses_geo_bordeaux %>% left_join(bv_bordeaux,by="id_brut_reu")


#liste des résultats aux européennes par bureau de vote
#attention : fichier très long à récupérer (plus d'une heure)
result_europ_bv <- readxl::read_excel(paste0(chemin,"/resultats-definitifs-par-bureau-de-vote.xlsx"))

#Résultats aux européennes à Bordeaux
result_europ_bv_bordeaux <- result_europ_bv %>% 
  filter(`Code commune`== ville) %>% 
  mutate(id_brut_reu = paste(`Code commune`,`Code BV`,sep = "_")) %>% 
  select(id_brut_reu,everything())

#jointure avec le fichier des adresses et des bureaux de vote
adresses_bv_result_geo_bordeaux <- adresses_bv_geo_bordeaux %>% 
  left_join(result_europ_bv_bordeaux,by="id_brut_reu") %>% 
  clean_names() #pour nettoyer les noms des variables

convert_to_numeric <- function(x) {
  as.numeric(gsub(",", ".", x))
  }

#on transforme en numérique des qualitatives
adresses_bv_result_geo_bordeaux_clean <- adresses_bv_result_geo_bordeaux %>%
  mutate(across(starts_with("percent"), ~ gsub("%", "", .))) %>%
  mutate(across(starts_with("percent"), convert_to_numeric))

#on stocke cet objet
st_write(obj = adresses_bv_result_geo_bordeaux_clean, 
         dsn = "bv_europe_bordeaux.gpkg")


  ggplot() +
  geom_sf(data = adresses_bv_result_geo_bordeaux_clean) +
  geom_point(data = adresses_bv_result_geo_bordeaux_clean, aes(color = value), size = 3) +
  scale_color_gradient(low = "blue", high = "red", name = "Valeur") +
  labs(title = "Carte avec points colorés selon 'value'")
  


#Carte avec toutes les adresses par bureau de vote à Bordeaux
mapview(adresses_bv_geo_bordeaux,zcol = "voie_reu",legend=TRUE)






