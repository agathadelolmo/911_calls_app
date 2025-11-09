library(shiny)
library(leaflet)
library(dplyr)
library(sf)

ui <- fluidPage(
  titlePanel("Mapa de emergencias - Monroe County"),

  fluidRow(
    column(
      width = 9,
      leafletOutput("map", height = "90vh")
    ),
    column(
      width = 3,
      wellPanel(
        h4("Información más cercana"),
        uiOutput("info_panel"),
        hr(),
        actionButton("refresh", "🔄 Actualizar datos", class = "btn btn-primary", style = "width:100%"),
        textOutput("last_update")
      )
    )
  )
)

server <- function(input, output, session) {

  load("hospital_data.RData")
  load("police_data.RData")

  hospitales <- hospital_data
  policia <- police_data

  cargar_datos <- function() {
    if (file.exists("calls_sf.rds")) {
      readRDS("calls_sf.rds")
    } else {
      NULL
    }
  }

  datos <- reactiveVal(cargar_datos())

  cols <- c(
    "🔴 ESPERANDO" = "#FF0000",
    "🟠 ENVIADO" = "#FFA500",
    "🟡 EN RUTA" = "#FCD53F",
    "🟢 EN ESCENA" = "#00FF00"
  )

  pal <- function(x) {
    res <- cols[as.character(x)]
    res[is.na(res)] <- "grey"
    unname(res)
  }

  # Renderizado inicial del mapa
  output$map <- renderLeaflet({
    calls_sf <- datos()
    validate(need(!is.null(calls_sf), "No hay datos cargados todavía. Pulsa 'Actualizar datos'."))
    leaflet(calls_sf) %>%
      addProviderTiles("CartoDB.Voyager") %>%
      addCircleMarkers(
        fillColor = ~pal(estado),
        fillOpacity = 0.7,
        stroke = FALSE,
        radius = 10,
        popup = ~paste0(
          "<b>Tipo:</b> ", tipo, "<br>",
          "<b>Dirección:</b> ", direccion, "<br>",
          "<b>Estado:</b> ", estado, "<br>",
          "<b>Hora:</b> ", hora, " ", "<b>Fecha:</b> ", fecha
        ),
        layerId = ~codigo,
        group = "calls"
      ) %>%
      addLegend("bottomright",
                colors = unname(cols),
                labels = names(cols),
                title = "Estado de llamada")
  })

  # Botón de actualización
  observeEvent(input$refresh, {
    showModal(modalDialog(
      "Actualizando datos, por favor espera...",
      footer = NULL
    ))

    system("Rscript scrape_monroe.R", wait = TRUE)
    removeModal()

    new_data <- cargar_datos()
    validate(need(!is.null(new_data), "Error al cargar los datos actualizados"))
    datos(new_data)
    showNotification("Datos actualizados ✅", type = "message")

    output$last_update <- renderText({
      paste("Última actualización:", format(Sys.time(), "%H:%M:%S"))
    })

    leafletProxy("map", data = new_data) %>%
      clearMarkers() %>%
      addCircleMarkers(
        fillColor = ~pal(estado),
        fillOpacity = 0.7,
        stroke = FALSE,
        radius = 10,
        popup = ~paste0(
          "<b>Tipo:</b> ", tipo, "<br>",
          "<b>Dirección:</b> ", direccion, "<br>",
          "<b>Estado:</b> ", estado, "<br>",
          "<b>Hora:</b> ", hora, " ",  "<b>Fecha:</b> ", fecha
        ),
        layerId = ~codigo,
        group = "calls"
      )
  })

  # Panel lateral
  output$info_panel <- renderUI({
    tagList(
      p("Haz clic en una llamada en el mapa para ver el hospital y la estación de policía más cercanos.")
    )
  })

  # Clic en marcador: calcular rutas y mostrar info
  # Clic en marcador: calcular rutas y mostrar info
  observeEvent(input$map_marker_click, {
    click <- input$map_marker_click
    if (is.null(click$id)) return()

    calls_sf <- datos()
    call_sel <- calls_sf[calls_sf$codigo == click$id, ]
    if (nrow(call_sel) == 0) return()

    showModal(modalDialog("Calculando rutas...", footer = NULL))
    source("rutas_openroutes.R")

    rutas <- calcular_rutas(
      lon = st_coordinates(call_sel)[1],
      lat = st_coordinates(call_sel)[2],
      hospitales = hospitales,
      policia = policia
    )
    removeModal()

    # Verificación de coordenadas
    if (is.null(st_geometry(rutas$hospital$destino)) || is.null(st_geometry(rutas$policia$destino))) {
      showNotification("⚠️ No se pudieron obtener coordenadas del hospital o la policía", type = "error")
      return()
    }

    hosp_coords <- st_coordinates(rutas$hospital$destino)
    pol_coords  <- st_coordinates(rutas$policia$destino)

    duration_hospital_min <- round(rutas$hospital$route$summary[[1]]$duration/60)
    distance_hospital_km <- round(rutas$hospital$route$summary[[1]]$distance/1000, 2)

    duration_police_min <- round(rutas$policia$route$summary[[1]]$duration/60)
    distance_police_km <- round(rutas$policia$route$summary[[1]]$distance/1000, 2)

    leafletProxy("map") %>%
      clearGroup("rutas") %>%
      addPolylines(
        data = rutas$hospital$route,
        color = "red", weight = 4, opacity = 0.8, group = "rutas",
        label = htmltools::HTML(paste0(
          "🏥 Ruta al hospital más cercano<br>",
          "<b>Duración:</b> ", duration_hospital_min, " min<br>",
          "<b>Distancia:</b> ", distance_hospital_km, " km"
        ))
      ) %>%
      addPolylines(
        data = rutas$policia$route,
        color = "blue", weight = 4, opacity = 0.8, group = "rutas",
        label = htmltools::HTML(paste0(
          "👮 Ruta a la comisaría más cercana<br>",
          "<b>Duración:</b> ", duration_police_min, " min<br>",
          "<b>Distancia:</b> ", distance_police_km, " km"
        ))
      ) %>%
      addCircleMarkers(
        lng = hosp_coords[1], lat = hosp_coords[2],
        color = "red", radius = 8, fillOpacity = 0.9,
        group = "rutas",
        popup = htmltools::HTML(paste0(
          "🏥 <b>", rutas$hospital$destino$name, "</b><br>",
          "Dir: ", rutas$hospital$destino$street, "<br>",
          "CP: ", rutas$hospital$destino$city_zip, "<br>",
          "Tel: ", rutas$hospital$destino$phone, "<br>",
          "Web: ", rutas$hospital$destino$website
        ))
      ) %>%
      addCircleMarkers(
        lng = pol_coords[1], lat = pol_coords[2],
        color = "blue", radius = 8, fillOpacity = 0.9,
        group = "rutas",
        popup = htmltools::HTML(paste0(
          "👮 <b>", rutas$policia$destino$name, "</b><br>",
          "Dir: ", rutas$policia$destino$street, "<br>",
          "CP: ", rutas$policia$destino$city_zip, "<br>",
          "Tel: ", rutas$policia$destino$phone, "<br>",
          "Web: ", rutas$policia$destino$website
        ))
      )

    # Actualizar panel lateral
    output$info_panel <- renderUI({
      tagList(
        h5("🏥 Hospital más cercano"),
        HTML(paste0(
          "<b>", rutas$hospital$destino$name, "</b><br>",
          "Dir: ", rutas$hospital$destino$street, "<br>",
          "CP: ", rutas$hospital$destino$city_zip, "<br>",
          "Tel:", rutas$hospital$destino$phone, "<br>",
          "Web:", rutas$hospital$destino$website
        )),
        hr(),
        h5("👮 Estación de policía más cercana"),
        HTML(paste0(
          "<b>", rutas$policia$destino$name, "</b><br>",
          "Dir: ", rutas$policia$destino$street, "<br>",
          "CP: ", rutas$policia$destino$city_zip, "<br>",
          "Tel:", rutas$policia$destino$phone, "<br>",
          "Web:", rutas$policia$destino$website
        ))
      )
    })

    showNotification(
      paste0("Rutas actualizadas para ", rutas$hospital$destino$name, " y ", rutas$policia$destino$name),
      type = "message"
    )
  })

}

shinyApp(ui, server)
