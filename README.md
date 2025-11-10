--- Español ---

APLICACIÓN LLAMADAS 911

-- Para usar la app --

https://agathadelolmotirado.shinyapps.io/app_emergency_calls/

Nota: Necesitarás una clave API gratuita de OpenRouteService: https://account.heigit.org/


-- Para seguir el mismo flujo de trabajo deade R --

Aplicación Shiny interactiva que muestra las llamadas más recientes al 911 en Monroe County, NY y calcula las rutas hacia el hospital y la comisaría de policía más cercanos.

Nota: La interfaz de la aplicación está en español.

Funcionalidades
- Visualiza las llamadas 911 con marcadores de colores según el estado
- Muestra el hospital y la estación de policía más cercanos
- Calcula y muestra las rutas en coche desde la ubicación de la llamada hasta ambos puntos

Requisitos
- R (>= 4.0)
- Firefox
- Guardar todos los archivos en un mismo directorio

Paquetes de R necesarios:

install.packages(c("shiny", "leaflet", "dplyr", "sf", "htmltools", "remotes"))
remotes::install_github("GIScience/openrouteservice-r")

Configuración
1) Obtén una clave gratuita de OpenRouteService: https://account.heigit.org/
2) Ejecuta app.R en RStudio para abrir la aplicación Shiny.

Uso
- Añade tu clave API OSR a "🔑 Introduce tu API key de OpenRouteService:".
- Haz clic en un marcador de llamada para ver las rutas hacia el hospital y la estación de policía más cercanos.
- Haz clic en "Actualizar" para obtener la información más reciente de las llamadas 911.


--- English ---

911 CALLS APP

-- To use the app --

https://agathadelolmotirado.shinyapps.io/app_emergency_calls/

Note: You will need a free OpenRouteService API key: https://account.heigit.org/

-- To follow the same workflow in R --

Interactive Shiny application that maps the most recent 911 calls in Monroe County, NY and displays routes to the nearest hospital and police station.

Note: The app interface is in Spanish.

Features
- Visualize 911 calls with color-coded markers based on status
- Display the nearest hospital and police station
- Show driving routes from the call location to both facilities

Requirements
- R (>= 4.0)
- Firefox
- Save all the files in the same directory

R packages required

install.packages(c("shiny", "leaflet", "dplyr", "sf", "htmltools", "remotes"))
remotes::install_github("GIScience/openrouteservice-r")

Setup
1) Obtain a free OpenRouteService API key: https://account.heigit.org/
2) Launch the Shiny app by opening and running app.R in RStudio.

Usage
- Add your OSR API key to "🔑 Introduce tu API key de OpenRouteService:".
- Click on a call marker to see the routes to the nearest hospital and police station.
- Click on "Actualizar" to fetch the latest information on 911 calls.
