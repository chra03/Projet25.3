
source("library.R")





wba <- "SORTIE/"
wcarto <- "../cartographie_CO2/"

DATA_TEMPO <- read.csv2(paste0(wba, "DATA_TEMPO_1E.csv"), fileEncoding = "latin1")
unique(DATA_TEMPO$MILLESIME)

DATA_TEMPO23 <- DATA_TEMPO %>%
  filter(MILLESIME == "2023")

DATA_TEMPO24 <- DATA_TEMPO %>%
  filter(MILLESIME == "2024")



GARES_DEP <- c("ENSEMBLE DES PARCOURS", unique(DATA_TEMPO23$Départ))

GARES_ARR <- c("ENSEMBLE DES PARCOURS",unique(DATA_TEMPO23$Arrivée))

# names(DATA_TEMPO24)








dataCam <- read.csv2(paste0(wba, "REPARTITION_TRANSPORTS.csv"), fileEncoding = "latin1")%>%
  filter(Mode.de.transport != "Transport ferroviaire")
dataCam$Mode.de.transport <- str_replace_all(dataCam$Mode.de.transport ,c("1" = "", "2"="","3"="","6"=""))
# unique(dataCam$Mode.de.transport)

dataEvo <- read.csv2(paste0(wba, "EVO_FER.csv"), fileEncoding = "latin1")





dataCO2 <- read.csv2(paste0(wba, "DATA_TONNE_CO2_LIO.csv"), fileEncoding = "latin1") %>%
  filter(TYPE != "Ensemble")%>%
  mutate(TONNNE_CO2_VOIT = (NOMBRE*0.2)/1000)%>%
  mutate(TONNNE_CO2_ECO = TONNNE_CO2_VOIT - TONNNE_CO2_EMIS)

dataCO2$TYPE <- str_replace_all(dataCO2$TYPE, c("Fr\u008equents" = "Fréquents"))


names(dataCO2)




data_cal <- read_excel(paste0(wba, "comparaison.xlsx")) %>%
  dplyr :: select(Origine,Destination ,`Type tarif`,Nombre_voyage_mois ,Gain_estimé )%>%
  rename("Type_tarif" = `Type tarif`)


# names(data_cal)








# unique(dataCO2$TYPE)

# # Charger les données depuis un fichier CSV
df <- read.csv2(paste0(wba, "TAB_1E_POS.csv"), sep = ";", stringsAsFactors = FALSE, fileEncoding = "latin1")%>%
  dplyr :: select(-Nombre.d.abonnements)%>%
  filter(NB_PERS > 1000)%>%
  rename("Nombre de personnes ayant effectué le trajet" = "NB_PERS") %>%
  rename("Kg de CO2 émis par passagers par<br> Km en TER pour ce trajet" = "KCO2_TER_km_tot")%>%
  rename("Kg de CO2 émis par passagers par <br>Km en Voiture pour ce trajet" = "KCO2_Voit_km_tot")%>%
  rename("Kg de CO2 économisé par passagers par <br>Km grâce au Lio train pour ce trajet" = "ECO_CO2_km_pers")
# names(df)
df$MILLESIME <- as.character(df$MILLESIME )



ANNEE1E <- c(unique(df$MILLESIME))
MOIS1E <- c(unique(df$MOIS))

c("Janvier","Février","Mars","Avril","Mai","Juin","Septembre","Octobre","Novembre","Décembre")









