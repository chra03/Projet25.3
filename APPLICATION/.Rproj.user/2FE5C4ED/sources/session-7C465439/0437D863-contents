
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








# # Charger les données depuis un fichier CSV
df <- read.csv2(paste0(wba, "TAB_1E_POS.csv"), sep = ";", stringsAsFactors = FALSE, fileEncoding = "latin1")

ANNEE1E <- c(unique(df$MILLESIME))
MOIS1E <- c(unique(df$MOIS))

c("Janvier","Février","Mars","Avril","Mai","Juin","Septembre","Octobre","Novembre","Décembre")
