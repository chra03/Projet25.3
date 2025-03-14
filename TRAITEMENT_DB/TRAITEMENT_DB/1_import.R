


source("library.R")

wba <- "BASES/"
wso <- "SORTIE/"

## Données pour la repartition des voyages selon le type de transport 

transport <- read_excel(paste0(wba, "sect-trans-tiv-mode.xlsx"), skip = 3)
colnames(transport) <- make.names(colnames(transport))
col_mil <- c("X2012","X2013","X2014","X2015","X2016","X2017","X2018","X2019","X2020","X2021","X2022")

KGCOD_ter <- 0.0244



transport <- transport %>%
  filter(!is.na(X2017))
transport2 <- transport %>%
  filter(str_detect(Mode.de.transport, "particuliers|autocars|Transport" ))
data_repart_voy <- transport2 %>%
  dplyr:: select(Mode.de.transport, X2022 ) 
write.csv2(data_repart_voy, paste0(wso, "REPARTITION_TRANSPORTS.csv"), fileEncoding = "latin1", row.names = F)


data_evo_fer <- transport2 %>%
  filter(Mode.de.transport == "Transports ferrés3")%>%
  pivot_longer(cols = col_mil, names_to = "MILLESIME", values_to = "VOY_KM")%>%
  dplyr :: select(Mode.de.transport,MILLESIME,VOY_KM)
data_evo_fer$MILLESIME <- str_replace_all(data_evo_fer$MILLESIME, c("X" = ""))
write.csv2(data_evo_fer, paste0(wso, "EVO_FER.csv"), fileEncoding = "latin1", row.names = F)





data_form <- read.csv2(paste0(wba, "Marathon du web.csv"))
data_form2 <- data_form %>%
  dplyr :: select(TOTAL, X2023, X2024) %>%
  pivot_longer(cols = c("X2023", "X2024"), names_to = "MILLESIME", values_to = "NOMBRE")%>%
  filter(TOTAL != "")

data_form2$TYPE <- ifelse(data_form2$TOTAL == "Jeunes", "Jeunes",
                          ifelse(data_form2$TOTAL == "Fréquents", "Fréquents",
                                 ifelse(data_form2$TOTAL == "Occasionnels", "Occasionnels",
                                        ifelse(data_form2$TOTAL == "+=", "+=",
                                               ifelse(data_form2$TOTAL == "WE 1€", "WE 1€", NA)))))


data_form3 <- data_form2 %>%
  fill(TYPE, .direction = "down")%>%
  mutate(TYPE = replace_na(TYPE, "Ensemble"))%>%
  filter(!(TOTAL %in% c("Jeunes","Fréquents", "Occasionnels" , "+=", "WE 1€"))) 



data_CO2 <- data_form3 %>%
  filter(TOTAL== "Distance totale annuelle en km") 
data_CO2$NOMBRE <- str_replace_all(data_CO2$NOMBRE, c(" " = ""))
data_CO2$NOMBRE <- as.numeric(data_CO2$NOMBRE)
data_CO2 <- data_CO2%>%
  mutate(
    NOMBRE = as.numeric(NOMBRE),
    # KGCOD_ter = as.numeric(KGCOD_ter),
    TONNNE_CO2_EMIS = ((NOMBRE * KGCOD_ter)/1000)
  )
data_CO2$MILLESIME <- str_replace_all(data_CO2$MILLESIME, c("X" = ""))

write.csv2(data_CO2, paste0(wso, "DATA_TONNE_CO2_LIO.csv"), row.names = F)









data_voit <- read.csv2(paste0(wba, "etude-facteurs-d'emissions-des-differents-modes-de-transport-routier.csv"), sep = ",")














data1 <- read.csv2(paste0(wba, "WE 1€ 2023.csv"), fileEncoding = "latin1")
colnames(data1) <- paste0(colnames(data1), "_2023")

data2 <- read.csv2(paste0(wba, "WE 1€ 2024.csv"), fileEncoding = "latin1")
colnames(data2) <- paste0(colnames(data2), "_2024")

data1E <- data1 %>%
  inner_join(data2, by = c("ï..Parcours_2023" = "ï..Parcours_2024") ) %>%
  rename("ï..Parcours_2023" = "PARCOURS")
data1E$ï..Parcours_2023 <- str_replace_all(data1E$ï..Parcours_2023, c("PARCOURS" = "ï..Parcours_2023"))
names(data1E)

write.csv2(data1E, paste0(wso, "DATA_1E_2023_2024.csv"), fileEncoding = "latin1", row.names = F)







# 
# feuilles <- c("Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Septembre", "Octobre", "Novembre", "Décembre")
# 
# library(readxl)
# library(dplyr)

# Liste des feuilles à importer
feuilles <- c("Janvier", "Février", "Mars", "Avril", "Mai", "Juin", 
              "Septembre", "Octobre", "Novembre", "Décembre")


#Pour l'annéee 2023
# Création d'une liste pour stocker les données
liste_data <- list()

# Boucle pour lire chaque feuille et ajouter les colonnes
for (feu in feuilles) {
  temp_data <- read_excel(paste0(wba, "WE 1€ 2023 Modifié.xlsx"), sheet = feu) %>%
    mutate(MOIS = feu, MILLESIME = "2023")  # Ajout des colonnes
  
  liste_data[[feu]] <- temp_data  # Stockage dans la liste
}



# Empiler toutes les données en un seul data frame
 data_finale23 <- bind_rows(liste_data) %>%
  filter(!str_detect(Parcours, "Filtres"), !is.na(Parcours))
 
 
 #Pour l'annéee 2024
 
 # Création d'une liste pour stocker les données
 liste_data <- list()
 
 # Boucle pour lire chaque feuille et ajouter les colonnes
 for (feu in feuilles) {
   temp_data <- read_excel(paste0(wba, "WE 1€ 2024modif.xlsx"), sheet = feu) %>%
     mutate(MOIS = feu, MILLESIME = "2024")  # Ajout des colonnes
   
   liste_data[[feu]] <- temp_data  # Stockage dans la liste
 }
 
 # Empiler toutes les données en un seul data frame
 data_finale24 <- bind_rows(liste_data) %>%
   filter(!str_detect(Parcours, "Filtres"), !is.na(Parcours))
 
 
 
 
data_finale1E <- bind_rows(data_finale23, data_finale24)
data_finale1E$Parcours <- str_replace_all(data_finale1E$Parcours, c("Total" = "ENSEMBLE DES PARCOURS"))
data_finale1E$Départ <- str_replace_all(data_finale1E$Départ, c("Total" = "ENSEMBLE DES PARCOURS"))
data_finale1E$Arrivée[is.na(data_finale1E$Arrivée)] <- "ENSEMBLE DES PARCOURS"

unique(data_finale1E$MILLESIME)
write.csv2(data_finale1E, paste0(wso, "DATA_TEMPO_1E.csv"), fileEncoding = "latin1", row.names = F)








# Traitement des données pour casser separer les parcours en depart   arrivée les longitutudes, latitudes 



# Liste des feuilles à importer
feuilles <- c("Janvier", "Février", "Mars", "Avril", "Mai", "Juin", 
              "Septembre", "Octobre", "Novembre", "Décembre")


#Pour l'annéee 2023
# Création d'une liste pour stocker les données
liste_data <- list()

# Boucle pour lire chaque feuille et ajouter les colonnes
for (feu in feuilles) {
  temp_data <- read_excel(paste0(wba, "WE 1€ 2023.xlsx"), sheet = feu) %>%
    mutate(MOIS = feu, MILLESIME = "2023")  # Ajout des colonnes
  
  liste_data[[feu]] <- temp_data  # Stockage dans la liste
}



# Empiler toutes les données en un seul data frame
data_finale23 <- bind_rows(liste_data) %>%
  filter(!str_detect(Parcours, "Filtres"), !is.na(Parcours))


#Pour l'annéee 2024

# Création d'une liste pour stocker les données
liste_data <- list()

# Boucle pour lire chaque feuille et ajouter les colonnes
for (feu in feuilles) {
  temp_data <- read_excel(paste0(wba, "WE 1€ 2024.xlsx"), sheet = feu) %>%
    mutate(MOIS = feu, MILLESIME = "2024")  # Ajout des colonnes
  
  liste_data[[feu]] <- temp_data  # Stockage dans la liste
}

# Empiler toutes les données en un seul data frame
data_finale24 <- bind_rows(liste_data) %>%
  filter(!str_detect(Parcours, "Filtres"), !is.na(Parcours))




data_finale1E_col <- bind_rows(data_finale23, data_finale24)
data_finale1E_col$Parcours <- str_replace_all(data_finale1E_col$Parcours, c("Total" = "ENSEMBLE DES PARCOURS"))


sepa_test <- data_finale1E_col %>%
  separate(Parcours, into = c("Depart", "Arrivee","reste"), sep = " - ") 

sepa_test$Parcous <- data_finale1E_col$Parcours

sepa_test <- sepa_test%>%
  filter(is.na(reste))%>%
  filter(`Nombre de voyages` >= 100)%>%
  dplyr :: select(-reste)

lis_gare <- read.csv2(paste0(wba, "tt_gare.csv"),sep = "," ) %>%
  dplyr :: select(Nom, Position.géographique)


jointure_dep <- sepa_test %>%
  inner_join(lis_gare, by=c("Depart" = "Nom")) %>%
  rename("Geom_depart" = "Position.géographique")

jointure_arr <- jointure_dep %>%
  inner_join(lis_gare, by=c("Arrivee" = "Nom")) %>%
  rename("Geom_arrivee" = "Position.géographique")
  
KGCOD_ter <- 0.0244
KGCOD_voit <- 0.2

TAB_1E_POS <- jointure_arr %>%
  rename("NB_PERS" = `Nombre de voyages`)%>%
  mutate(KCO2_TER_km_tot = NB_PERS*KGCOD_ter)%>%
  mutate(KCO2_Voit_km_tot = NB_PERS*KGCOD_voit)%>%
  mutate(ECO_CO2_km_pers = KCO2_Voit_km_tot-KCO2_TER_km_tot)

write.csv2(TAB_1E_POS, paste0(wso, "TAB_1E_POS.csv"), fileEncoding = "latin1", row.names = F)

names(TAB_1E_POS)

