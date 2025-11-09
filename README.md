--- Español ---

Aplicación Llamadas 911

Aplicación Shiny interactiva que muestra las llamadas más recientes al 911 en Monroe County, NY y calcula las rutas hacia el hospital y la comisaría de policía más cercanos.

Nota: La interfaz de la aplicación está en español.

Funcionalidades
- Visualiza las llamadas 911 con marcadores de colores según el estado
- Muestra el hospital y la estación de policía más cercanos
- Calcula y muestra las rutas en coche desde la ubicación de la llamada hasta ambos puntos

Requisitos
- R (>= 4.0)
- Firefox

Paquetes de R necesarios:
install.packages(c("shiny", "leaflet", "dplyr", "sf", "htmltools", "remotes"))
remotes::install_github("GIScience/openrouteservice-r")

Configuración
1) Obtén una clave gratuita de OpenRouteService: https://account.heigit.org/
2) En RStudio, ejecuta:
library(openrouteservice)
ors_api_key("TU_CLAVE_AQUI")
3) Ejecuta app.R en RStudio para abrir la aplicación Shiny.

Uso
- Haz clic en un marcador de llamada para ver las rutas hacia el hospital y la estación de policía más cercanos.
- Haz clic en Actualizar para obtener la información más reciente de las llamadas 911.


--- English ---

911 Calls App

Interactive Shiny application that maps the most recent 911 calls in Monroe County, NY and displays routes to the nearest hospital and police station.

Note: The app interface is in Spanish.

Features
- Visualize 911 calls with color-coded markers based on status
- Display the nearest hospital and police station
- Show driving routes from the call location to both facilities

Requirements
- R (>= 4.0)
- Firefox (or any browser supported by Shiny)

R packages required
install.packages(c("shiny", "leaflet", "dplyr", "sf", "htmltools", "remotes"))
remotes::install_github("GIScience/openrouteservice-r")

Setup
1) Obtain a free OpenRouteService API key: https://account.heigit.org/
2) In RStudio, run:
library(openrouteservice)
ors_api_key("YOUR_API_KEY_HERE")
3) Launch the Shiny app by opening and running app.R in RStudio.

Usage
- Click on a call marker to see the routes to the nearest hospital and police station.
- Click on actualizar to fetch the latest information on 911 calls
