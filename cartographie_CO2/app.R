# Installer les packages nécessaires si ce n'est pas déjà fait
# install.packages(c("shiny", "htmlabilities"))

library(shiny)
library(htmlabilities)

# Définir votre clé API Google Maps
api_key <- "VOTRE_CLE_API"

# Liste des villes principales d'Occitanie
occitanie_cities <- c(
  "Montpellier", "Toulouse", "Nîmes", "Perpignan", "Béziers", 
  "Albi", "Narbonne", "Tarbes", "Sète", "Carcassonne", 
  "Rodez", "Castres", "Alès", "Montauban", "Cahors", 
  "Millau", "Auch", "Mende", "Foix", "Lourdes"
)

# Interface utilisateur
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        font-family: 'Roboto', Arial, sans-serif;
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
      }
      
      h2 {
        color: #1a73e8;
        text-align: center;
        margin-bottom: 20px;
      }
      
      .form-group {
        margin-bottom: 15px;
      }
      
      .map-container {
        width: 100%;
        height: 600px;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      }
      
      iframe {
        border: 0;
        width: 100%;
        height: 100%;
      }
      
      .city-button {
        margin: 5px;
      }
      
      .note {
        margin-top: 20px;
        font-size: 14px;
        color: #5f6368;
        text-align: center;
      }
    "))
  ),
  
  titlePanel("Transports en Occitanie"),
  
  sidebarLayout(
    sidebarPanel(
      # Lieu de départ
      selectizeInput(
        "origin", 
        "Lieu de départ:",
        choices = c("", occitanie_cities),
        options = list(
          create = TRUE,
          placeholder = "Saisissez ou sélectionnez un lieu de départ"
        )
      ),
      
      # Destination
      selectizeInput(
        "destination", 
        "Destination:",
        choices = c("", occitanie_cities),
        options = list(
          create = TRUE,
          placeholder = "Saisissez ou sélectionnez une destination"
        )
      ),
      
      # Bouton pour rechercher l'itinéraire
      actionButton("find_route", "Rechercher un itinéraire", 
                   class = "btn-primary btn-block"),
      
      # Villes populaires
      tags$div(
        style = "margin-top: 20px;",
        tags$p("Villes populaires:"),
        tags$div(
          style = "display: flex; flex-wrap: wrap;",
          lapply(occitanie_cities[1:6], function(city) {
            actionButton(paste0("city_", gsub(" ", "_", city)), city, 
                         class = "btn-sm btn-light city-button")
          })
        )
      ),
      
      width = 3
    ),
    
    mainPanel(
      # Conteneur pour la carte
      tags$div(
        class = "map-container",
        tags$iframe(
          id = "map_iframe",
          src = paste0("https://www.google.com/maps/embed/v1/view?key=", api_key, 
                       "&center=43.8927,3.2828&zoom=7&region=fr"),
          width = "100%",
          height = "100%",
          frameborder = "0",
          allowfullscreen = NA
        )
      ),
      
      # Note explicative
      tags$p(
        class = "note",
        "Sélectionnez un lieu de départ et une destination pour afficher les itinéraires en transport en commun."
      ),
      
      width = 9
    )
  )
)

# Serveur
server <- function(input, output, session) {
  # Fonction pour mettre à jour l'iframe avec les directions
  updateMapDirections <- function(origin, destination) {
    if (origin != "" && destination != "") {
      iframe_src <- paste0(
        "https://www.google.com/maps/embed/v1/directions?key=", api_key,
        "&origin=", URLencode(origin),
        "&destination=", URLencode(destination),
        "&mode=transit&region=fr"
      )
      
      session$sendCustomMessage(
        type = "updateIframeSrc",
        message = list(id = "map_iframe", src = iframe_src)
      )
    }
  }
  
  # Observer pour le bouton de recherche d'itinéraire
  observeEvent(input$find_route, {
    updateMapDirections(input$origin, input$destination)
  })
  
  # Observers pour les boutons de villes populaires
  lapply(occitanie_cities[1:6], function(city) {
    city_id <- paste0("city_", gsub(" ", "_", city))
    observeEvent(input[[city_id]], {
      # Si aucun lieu de départ n'est sélectionné, définir cette ville comme départ
      if (input$origin == "") {
        updateSelectizeInput(session, "origin", selected = city)
      } 
      # Sinon, si aucune destination n'est sélectionnée, définir cette ville comme destination
      else if (input$destination == "") {
        updateSelectizeInput(session, "destination", selected = city)
      }
      # Si les deux sont déjà définis, remplacer la destination
      else {
        updateSelectizeInput(session, "destination", selected = city)
      }
    })
  })
}

# JavaScript personnalisé pour mettre à jour l'iframe
jsCode <- "
Shiny.addCustomMessageHandler('updateIframeSrc', function(message) {
  document.getElementById(message.id).src = message.src;
});
"

# Application complète
shinyApp(
  ui = tagList(
    ui,
    tags$script(HTML(jsCode))
  ),
  server = server
)