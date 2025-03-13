library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)

# Charger le fichier CSV
data <- read_csv("REPARTITION_TRANSPORTS.csv")

# Séparer la colonne 'Mode_de_transport;X2022' en deux colonnes : 'Mode_de_transport' et 'milliards_voyageurs_km'
data_separated <- data %>%
  separate(`Mode_de_transport;milliards_voyageurs_km`, into = c("Mode_de_transport", "Count"), sep = ";")

# Nettoyer les données
# Remplacer les virgules par des points pour les valeurs numériques
data_separated$Count <- gsub(",", ".", data_separated$Count)

# Convertir la colonne "Count" en numérique, avec un contrôle pour éviter les valeurs non numériques
data_separated$Count <- as.numeric(data_separated$Count)

# Vérifier s'il y a des NA après conversion
print(sum(is.na(data_separated$Count)))  # Afficher le nombre de valeurs manquantes

# Filtrer les lignes avec des valeurs manquantes si nécessaire
data_separated <- data_separated %>%
  filter(!is.na(Count))  # Enlever les lignes où "Count" est NA

# Calculer les pourcentages pour chaque mode de transport
data_separated$Percentage <- data_separated$Count / sum(data_separated$Count) * 100

# Voir un aperçu des données nettoyées
head(data_separated)

# Créer le graphique en camembert avec pourcentage
ggplot(data_separated, aes(x = "", y = Count, fill = Mode_de_transport)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  theme_void() +
  labs(title = "Répartition des Transports en Milliards de Voyageurs-Km", fill = "Mode de transport") +
  geom_text(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5))
