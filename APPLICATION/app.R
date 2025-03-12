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

# Listes des gares
GARES_DEP <- c("ENSEMBLE DES PARCOURS", unique(na.omit(DATA_TEMPO23$Départ)))
GARES_ARR <- c("ENSEMBLE DES PARCOURS", unique(na.omit(DATA_TEMPO23$Arrivée)))



# Rendre le dossier externe accessible
addResourcePath("cartographie", "../cartographie_CO2")


# Interface UI
ui <- dashboardPage(
  dashboardHeader(title = "MDW"),
  dashboardSidebar(
    use_theme(theme_perso),
    sidebarMenu(
      menuItem("Accueil", tabName = "accueil"),
      menuItem("Analyse", tabName = "analyse"),
      
      menuItem("Cartographie", tabName = "cartographie"),
      menuItem("Comparateur de CO2", tabName = "comparateur"),
      menuItem("Qui sommes nous ?", tabName = "quisommesnous")
    )
  ),
  dashboardBody(
    tags$head(tags$style(HTML("
      .content-wrapper {
        background-color: #f8f9fa !important;
      }
      .box {
        border-radius: 15px;
        box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
      }
    "))),
    
    tabItems(
      
      tabItem(tabName = "comparateur", 
              # h2("Partie de comparaison(anas)"),
              
              tags$iframe(src = "cartographie/index.html", width = "100%", height = "100%", style = "border: none; height: 100vh; width: 100%;")
              
      ),
      tabItem(tabName = "cartographie", h2("Partie cartographie")),
      tabItem(tabName = "accueil", h2("?????")),
      tabItem(tabName = "analyse",
              h2("Graphes d'analyse"), 
              fluidRow(
                # Première colonne pour les inputs
                column(3,  # Largeur de la colonne pour les inputs (ajustez selon le besoin)
                       selectInput("gareDEP", "Choix de la gare de départ", choices = GARES_DEP),
                       selectInput("gareARR", "Choix de la gare d'arrivée", choices = GARES_ARR)
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
        data = DATA_TEMPO24_react(), 
        x = ~MOIS, 
        y = ~Nombre.de.voyages, name =~MILLESIME,
        hoverinfo = 'x+text',  
        hovertext = ~paste(format(Nombre.de.voyages, big.mark = " "))
      ) %>%
      add_lines(
        data = DATA_TEMPO23_react()%>%
          mutate(MOIS = factor(MOIS, levels = c("Janvier","Février","Mars","Avril","Mai","Juin","Septembre","Octobre","Novembre","Décembre")
                               , ordered = F)), 
        x = ~as.factor(MOIS), 
        y = ~Nombre.de.voyages,  name =~MILLESIME,
        hoverinfo = 'x+text',  
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
  
  
  
  
}









# Lancement de l'application
shinyApp(ui = ui, server = server)