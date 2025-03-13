source("library.R")
source("import.R")

# Thème personnalisé
theme_perso <- create_theme(
  adminlte_color(
    light_blue = "#c34a36"
  ),
  adminlte_sidebar(
    dark_bg = "black",
    dark_hover_bg = "#4b4453",
    dark_color = "#ffffff"
  ),
  adminlte_global(
    content_bg = "#ffffff",
    box_bg = "#ffffff",
    info_box_bg = "#c34a36"
  )
)

# # Listes des gares
# GARES_DEP <- c("ENSEMBLE DES PARCOURS", unique(DATA_TEMPO23$Départ))
# GARES_ARR <- c("ENSEMBLE DES PARCOURS", unique(DATA_TEMPO23$Arrivée))
# 
# selected_gareDEP <- ifelse(length(GARES_DEP) > 0, GARES_DEP[1], "ENSEMBLE DES PARCOURS")
# selected_gareARR <- ifelse(length(GARES_ARR) > 0, GARES_ARR[1], "ENSEMBLE DES PARCOURS")


# Rendre le dossier externe accessible
addResourcePath("cartographie", "../cartographie_CO2")


# Interface UI
ui <- dashboardPage(
  dashboardHeader(title = tagList(
    span("MDW", style = "font-size: 18px; margin-left =0px")
  ),
                  tags$li(class = "dropdown",
                          # style = "margin-top: 5px; margin-right: 10px;",  # Espacement
                          imageOutput("logolio", inline = TRUE),
                          imageOutput("logomiashs", inline = TRUE),
                          imageOutput("logo", inline = TRUE)
                          
                  )
                  ),
  dashboardSidebar(
    use_theme(theme_perso),
    sidebarMenu(
      menuItem("Accueil", tabName = "accueil",icon = icon("house")),
      menuItem("Analyse", tabName = "analyse", icon = icon("chart-simple")),
      
     
      menuItem("Comparateur de CO2", tabName = "comparateur",icon = icon("globe")),
      menuItem("Calculateur de gains", tabName = "calcul_gains" ,icon = icon("percent")),
      menuItem("Qui sommes nous ?", tabName = "quisommesnous",icon = icon("question"))
    )
  ),
  dashboardBody(
    tags$head(tags$style(HTML("
   /* Style général */
body, .content-wrapper {
    background-color: #f4f4f4 !important;
    font-family: 'Roboto', sans-serif;
}

/* Personnalisation des boîtes */
.box {
    border-radius: 15px;
    box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.15);
    background-color: #ffffff !important;
}

/* Style des en-têtes */
.main-header .logo {
    background-color: #c34a36 !important;
    font-weight: bold;
    font-size: 18px;
}

.main-header .navbar {
    background-color: #c34a36 !important;
}

/* Style de la barre latérale */
.main-sidebar {
    background-color: #000000 !important;
}

.sidebar-menu > li > a {
    color: #ffffff !important;
    font-size: 16px;
    transition: 0.3s;
}

.sidebar-menu > li > a:hover {
    background-color: #4b4453 !important;
    border-radius: 10px;
}

/* Personnalisation des boutons */
.btn {
    border-radius: 8px;
    transition: 0.3s;
}

.btn-primary {
    background-color: #c34a36 !important;
    border: none;
}

.btn-primary:hover {
    background-color: #a33a2c !important;
}

/* Style des inputs */
.form-control {
    border-radius: 8px;
    border: 1px solid #ddd;
    padding: 10px;
}

.selectize-control {
    border-radius: 8px;
    border: 1px solid #ddd;
}

/* Style des tableaux */
table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
    border-radius: 10px;
    overflow: hidden;
}

table th {
    background: #c34a36;
    color: white;
    padding: 12px;
}

table td {
    padding: 10px;
    border-bottom: 1px solid #ddd;
}



h2 {
  font-family: 'Arial', sans-serif;
  font-size: 24px;
  font-weight: bold;
  color: #333;
  text-transform: uppercase;
  letter-spacing: 1px;
  padding: 10px 15px;
  text-align : center;
  border-left: 5px solid #c34a36;
  background: linear-gradient(to right, #f8f9fa, #ffffff);
  border-radius: 5px;
  box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);
}


/* Personnalisation des graphiques */
.plotly-container {
    border-radius: 15px;
    background: #ffffff;
    padding: 15px;
    box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
}

/* Footer */
.main-footer {
    background: #ffffff;
    text-align: center;
    padding: 10px;
    font-size: 14px;
    color: #555;
}



.map-container {
          border: 1px solid #c34a36;  /* Bordure de 5px avec une couleur personnalisée */
          border-radius: 10px;         /* Coins arrondis */
          padding: 1px;               /* Espacement interne */
        }

    "))),
    
    tabItems(
      
      tabItem(tabName = "comparateur", 
              # h2("Partie de comparaison(anas)"),
              
              tags$iframe(src = "cartographie/index.html", width = "100%", height = "100%", style = "border: none; height: 100vh; width: 100%;")
              
      ),
      tabItem(tabName = "cartographie", h2("Partie cartographie")),
      
      tabItem(tabName = "calcul_gains", 
              h2("Estimation des gains avec LIO Train"),
              fluidPage(
                titlePanel("Estimation des gains (en euros) sur un trajet"),
                
                sidebarLayout(
                  sidebarPanel(
                    selectInput("origine", "Origine :", choices = unique(data_cal$Origine)),
                    selectInput("destination", "Destination :", choices = unique(data_cal$Destination)),
                    sliderInput("voyages", "Nombre de voyages/mois :", min = 1, max = 60, value = 1)
                  ),
                  
                  mainPanel(
                    tableOutput("resultat")
                  )
                )
              ),HTML("
    <div style='font-family: Verdana, sans-serif; line-height: 1.8; color: black; font-size: 16px;'>


      <div style='margin-top: 1px; padding: 20px; border-radius: 15px; background: #ffffff; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); text-align: center;'>
    <p style='text-align: justify; margin: 0;'>
        Description : Le gain estimé en euros est calculé en faisant la différence entre le coût du trajet en voiture et le coût du trajet en Lio train.
    </p>
    </div>
     </div>
    ")
              
              
              
              
              
              
              
              
              ), 
              
              
              
      tabItem(tabName = "accueil", h2("?????")
              
              
              
              
              
              
              
              
              
              
              
              ),
      
      
      
      
      
      
      
      
      
      
      tabItem(tabName = "analyse",
              h2("Outils d'analyse"), 
              plotlyOutput("grapheCam", height = "400px"),
              HTML("
    <div style='font-family: Verdana, sans-serif; line-height: 1.8; color: black; font-size: 16px;'>


      <div style='margin-top: 1px; padding: 20px; border-radius: 15px; background: #ffffff; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); text-align: center;'>
    <p style='text-align: justify; margin: 0;'>
        Description : Cette répartition présente les statistiques sur le nombre de personnes se déplaçant à l'intérieur de la France, en utilisant différents modes de transport. Exprimée est milliards de km-voyageurs, Elle est calculée en multipliant le nombre de voyageurs par la distance qu'ils ont parcourue. 
    </p>
    </div>
     </div>
    "),
              hr(),hr(),
              plotlyOutput("grapheEvo", height = "400px"),hr(),hr(),
              plotlyOutput("grapheCO2", height = "400px"),
              HTML("
    <div style='font-family: Verdana, sans-serif; line-height: 1.8; color: black; font-size: 16px;'>


      <div style='margin-top: 1px; padding: 20px; border-radius: 15px; background: #ffffff; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); text-align: center;'>
    <p style='text-align: justify; margin: 0;'>
        Description : L'approximation de la quantité de CO2 annuelle emise par les voyageurs en train est effectuée en multipliant la distance totale parcourue par toutes les personnes en un an en TER par l'emission de CO2 en KgCO2/km/personne (0.0244 KgCO2/Km/Personne d'après la sncf).
        La quantité de CO2 économisée est obtenue par la différence entre cette émission et la quantité de CO2 émise en voiture pour les mêmes distances.
    </p>
    </div>
     </div>
    "),hr(),hr(),
              fluidRow(
                # Première colonne pour les inputs
                column(3,  # Largeur de la colonne pour les inputs (ajustez selon le besoin)
                       selectInput("gareDEP", "Choix de la gare de départ", choices = unique(DATA_TEMPO23$Départ)),
                       selectInput("gareARR", "Choix de la gare d'arrivée", choices = unique(DATA_TEMPO23$Arrivée))
                ),
                
                # Deuxième colonne pour le graphique
                column(9,  # Largeur de la colonne pour le graphique (ajustez selon le besoin)
                       box(
                         title = "ANALYSE PERSONNALISEE DES TRAJETS A 1€ le WEEK-END",
                         status = "primary",
                         solidHeader = TRUE,
                         width = 12,
                         plotlyOutput("graphe1", height = "380px")
        
                       )
                )
              ),hr(),hr(),
              fluidRow(
                column(3,
                       selectInput("annee1E", "Choix de l'année", choices = ANNEE1E),
                       selectInput("mois1E", "Choix du mois", choices = MOIS1E)
                       
                ),
                
                column(9,
                       div(
                         class = "map-container",
                         tmapOutput("carte_test", height = "600px",width = "auto")
                       )
                ) 
              ),
              
      ),
      tabItem(tabName = "quisommesnous", h2("Présentation"))
    )
  )
)






# Serveur
server <- function(input, output) {
  
  
  
  output$logolio <- renderImage({
    # Chemin du fichier image
    list(src = "IMAGES/Logo_LIO.png", 
         contentType = "image/png",width = "auto",  # Redimensionner côté serveur
         height = 50,
         alt = "Logo Observatoire")
  }, deleteFile = FALSE)
  
  
  output$logomiashs <- renderImage({
    # Chemin du fichier image
    list(src = "IMAGES/Logo_miashs.jpg", 
         contentType = "image/png",width = "auto",  # Redimensionner côté serveur
         height = 50,
         alt = "Logo Observatoire")
  }, deleteFile = FALSE)
  
  
  
  
  
  

  
  # Filtrer les données selon les entrées utilisateur
  output$resultat <- renderTable({
    # req(input$tarif)  # Empêche l'affichage avant que l'utilisateur ne sélectionne un tarif
    
    data_cal %>%
      filter(Origine == input$origine, 
             Destination == input$destination,
             # Type_tarif == input$tarif,
             Nombre_voyage_mois == input$voyages)%>%
      distinct(Origine,	Destination	,Type_tarif	,Nombre_voyage_mois,	Gain_estimé)
  })

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  DATA_TEMPO23_react <- reactive({
    req(input$gareDEP, input$gareARR)
    DATA_TEMPO23 %>%
      filter(Départ == input$gareDEP, Arrivée == input$gareARR)
  })
  
  DATA_TEMPO24_react <- reactive({
    req(input$gareDEP, input$gareARR)
    DATA_TEMPO24 %>%
      filter(Départ == input$gareDEP, Arrivée == input$gareARR)
  })
  
  output$graphe1 <- renderPlotly({
    graphe1 <-  plot_ly() %>%
      add_lines(
        data = DATA_TEMPO24_react()%>%
          mutate(MOIS = factor(MOIS, levels = c("Janvier","Février","Mars","Avril","Mai","Juin","Septembre","Octobre","Novembre","Décembre")
, ordered = F)),
        x = ~MOIS, line = list(shape = 'spline'),
        y = ~Nombre.de.voyages, name =~MILLESIME,
        hoverinfo = 'x+text',mode = 'lines+markers',
        hovertext = ~paste(format(Nombre.de.voyages, big.mark = " "))
      ) %>%
      add_lines(
        data = DATA_TEMPO23_react()%>%
          mutate(MOIS = factor(MOIS, levels = c("Janvier","Février","Mars","Avril","Mai","Juin","Septembre","Octobre","Novembre","Décembre")
                               , ordered = F)), 
        x = ~as.factor(MOIS), line = list(shape = 'spline'), 
        y = ~Nombre.de.voyages,  name =~MILLESIME,
        hoverinfo = 'x+text',  mode = 'lines+markers',
        hovertext = ~paste(format(Nombre.de.voyages, big.mark = " "))
      ) %>%
      layout(
        title = "Nombre de personnes ayant effectué le trajet par mois",
        margin = list(l = 50, r = 50, b = 40, t = 80),
        xaxis = list(title = "Mois"),
        yaxis = list(title = "Nombre de personnes"),
        paper_bgcolor = 'white',
        plot_bgcolor = "white",
        font = list(color = 'black')
      )
    
    graphe1
  })
  
  
  
  
  
  
  
  
  output$grapheCam <- renderPlotly({
    
    # Chargement des couleurs de la palette "YlGn"
    color_parc <- RColorBrewer::brewer.pal(n = length(unique(dataCam$Mode.de.transport)), "Dark2")
    
    
    grapheCam <- dataCam%>%
      mutate("Percent" = round((X2022*100)/(sum(X2022)),0)) %>%
      plot_ly(
        labels = ~Mode.de.transport,
        values = ~X2022,
        text = ~paste0(Percent,"%"),
        insidetextfont = list(color = 'white'),
        hoverinfo = 'text',
        hovertext= ~paste0( "Mode de transport : ", Mode.de.transport, '<br>Milliard de km voyageur : ' , format(X2022, big.mark = " "),  "<br>Proportion : ",Percent,'%'),
        textinfo = 'text',
        
        insidetextfont = list(color = 'black'),
        sort = F,
        marker = list(colors = color_parc))
    grapheCam <- grapheCam %>% add_pie(hole = 0.5, domain = list(x = c(1, 0.9), y = c(1,0.9))  )
    
    grapheCam <- grapheCam %>% layout(title= "Répartition du transport intérieur voyageur par mode de transport en 2022 <br>en millards de kilomètres-voyageurs",
                                          showlegend = T,
                                          margin = list(
                                            l = 50,  # marge gauche
                                            r = 50,  # marge droite
                                            b = 50,  # marge en bas
                                            t = 100  # marge en haut
                                          ),
                                          paper_bgcolor = 'white',  # couleur de fond du papier
                                          plot_bgcolor = 'white',
                                          font = list(color = 'black'),
                                          
                                          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                          
                                          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                          legend = list(
                                            traceorder = "normal",
                                            orientation = "h",   # Horizontal orientation
                                            bgcolor = ("rgba(0, 0, 0, 0)"),
                                            x = 0.5,             # Center the legend
                                            xanchor = "center",  # Align the center
                                            y = -0.1              # Position above the plot
                                            
                                          )
                                          
    )
      
    grapheCam
    
    
    
    
  })
  
  
  
  
  
  
  
  
  
  
  # the plot
  output$grapheEvo <- renderPlotly({

    grapheEvo <- plot_ly(dataEvo, x = ~as.factor(MILLESIME), y = ~VOY_KM, type = 'bar',
                          # color = ~Caracteristiques, 
                          marker=list(color = "#cf4f3d"),
                          hoverinfo = 'x+text',  # Information affichée au survol (année et texte)
                          text = ~format(VOY_KM, big.mark = " "),
                          textposition = 'inside',
                          textfont = list(color = 'white'))%>%
      layout(title = list(text = "Evolution des transports intérieurs de voyageurs par voies ferroviaires"),
             
             
             margin = list(
               l = 50,  # marge gauche
               r = 50,  # marge droite
               b = 50,  # marge en bas
               t = 100  # marge en haut
             ),
             xaxis = list(title = 'Année'),
             yaxis = list(title = 'Voyageurs-km (en Milliard)',tickformat = ",.")
             ,
             plot_bgcolor = 'white', # Couleur de fond du plot
             paper_bgcolor = 'white', # Couleur de fond du papier
             font = list(color = 'black')
      )
    
    grapheEvo
    
  })
  
  
  
  
  
  
  
  
  

  
  output$grapheCO2 <- renderPlotly({
    
    
    grapheCO2 <- plot_ly(dataCO2, x = ~TONNNE_CO2_ECO, y = ~paste0(MILLESIME," "), type = 'bar',orientation = "h",
                          color = ~TYPE, colors = "Dark2",text=~round(TONNNE_CO2_ECO, 2),
                          hoverinfo = 'text',  # Information affichée au survol (année et texte)
                          hovertext = ~paste('Catégorie : ', TYPE, '<br>CO2 total emis par les passagers en lio : ', round(TONNNE_CO2_EMIS,2),"tonnes",
                                             "<br>CO2 total emis par les passagers en voiture : ", round(TONNNE_CO2_VOIT, 2), "tonnes"),  # Texte affiché au survol
                          # text = ~paste0(round(pourcent,1),"%"),
                          textposition = 'auto',
                          outsidetextfont = list(color = 'black'),insidetextfont = list(color = 'white'),
                          showlegend = T) %>%
      layout(title =list (text= "Quantité de CO2 totale économisée en Lio train par les passagers selon leur typologie<br>en 2023 et en 2024"),
             margin = list(
               l = 50,  # marge gauche
               r = 50,  # marge droite
               b = 50,  # marge en bas
               t = 100  # marge en haut
             ),
             xaxis = list(title = "Quantité de CO2 économisée"),
             yaxis = list(title = ''),
             plot_bgcolor = 'white', # Couleur de fond du plot
             paper_bgcolor = 'white', # Couleur de fond du papier
             font = list(color = 'black')
             )
    
    
    
    
    
  })
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  # Réactivité pour filtrer les données selon l'année et le mois
  data_carte <- reactive({
    # req(input$annee1E, input$mois1E)
    
    # Nettoyage et séparation des coordonnées
    df_cleaned <- df %>%
      mutate(Geom_depart = trimws(Geom_depart),
             Geom_arrivee = trimws(Geom_arrivee)) %>%
      separate(Geom_depart, into = c("Lat_Depart", "Lon_Depart"), sep = ",", convert = TRUE) %>%
      separate(Geom_arrivee, into = c("Lat_Arrivee", "Lon_Arrivee"), sep = ",", convert = TRUE) %>%
      filter(MILLESIME == input$annee1E, MOIS == input$mois1E) %>%
      mutate(
        Lat_Depart = as.numeric(Lat_Depart),
        Lon_Depart = as.numeric(Lon_Depart),
        Lat_Arrivee = as.numeric(Lat_Arrivee),
        Lon_Arrivee = as.numeric(Lon_Arrivee)
      ) %>%
      drop_na(Lat_Depart, Lon_Depart, Lat_Arrivee, Lon_Arrivee)  # Supprimer les valeurs NA
    
    return(df_cleaned)
  })
  
  # Réactivité pour charger la carte des régions de France
  france <- ne_states(country = "France", returnclass = "sf") %>%
    filter(!name %in% c("Guyane française", "Martinique", "Guadeloupe", "La Réunion", "Mayotte")) %>%
    dplyr :: select(name, region, provnum_ne, geometry)
  
  occitanie <- france %>% filter(region == "Occitanie")
  
  # Créer la carte
  output$carte_test <- renderTmap({
    
    # Créer les objets sf pour les trajets, gares de départ et d'arrivée
    trajets_sf <- data_carte() %>%
      rowwise() %>%
      mutate(geometry = list(st_linestring(matrix(c(Lon_Depart, Lat_Depart, Lon_Arrivee, Lat_Arrivee), ncol = 2, byrow = TRUE)))) %>%
      ungroup() %>%
      st_as_sf(crs = 4326)  # Définir le système de projection WGS84
    
    gares_depart_sf <- data_carte() %>%
      dplyr::select(Depart, Lat_Depart, Lon_Depart) %>%
      distinct() %>%
      st_as_sf(coords = c("Lon_Depart", "Lat_Depart"), crs = 4326)
    
    gares_arrivee_sf <- data_carte() %>%
      dplyr::select(Arrivee, Lat_Arrivee, Lon_Arrivee) %>%
      distinct() %>%
      st_as_sf(coords = c("Lon_Arrivee", "Lat_Arrivee"), crs = 4326)
    
    # Mode interactif pour la carte tmap
    
    
    
    carte <- tm_basemap("OpenStreetMap") +
      tm_shape(occitanie) +
      tm_polygons(col = "lightgray", alpha = 0.3, border.col = "black", title = "Occitanie") +
      tm_shape(trajets_sf) +
      tm_lines(
        col = "Nombre de personnes ayant effectué le trajet",  # Couleur selon le nombre de voyageurs
        lwd = 2,
        palette = "magma",
        title.col = "Nombre de voyageurs"
      ) +
      tm_shape(gares_depart_sf) +
      tm_dots(
        col = "blue", size = 0.5, alpha = 0.8,
        id = "Depart",  # Afficher le nom de la gare au survol
        title = "Gares de départ"
      ) +
      
      tm_shape(gares_arrivee_sf) +
      tm_dots(
        col = "blue", size = 0.5, alpha = 0.8,
        id = "Arrivee",  # Afficher le nom de la gare au survol
        title = "Gares d'arrivée"
      ) +
      
      tm_layout(
        title = "Carte des trajets à 1€ en Occitanie",
        legend.outside = TRUE
      )
    
    
    carte
    
    
  })
  
  
  
  
  
}









# Lancement de l'application
shinyApp(ui = ui, server = server)