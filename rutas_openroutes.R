
library(openrouteservice)
library(sf)
library(dplyr)



calcular_rutas <- function(lon, lat, hospitales, policia, api_key) {

  origen <- st_sfc(st_point(c(lon, lat)), crs = 4326)

  dist_h <- st_distance(origen, hospitales)
  hospital_sel <- hospitales[which.min(dist_h), ]

  dist_p <- st_distance(origen, policia)
  policia_sel <- policia[which.min(dist_p), ]

  route_h <- openrouteservice::ors_directions(
    coordinates = list(
      c(lon, lat),
      c(st_coordinates(hospital_sel)[1], st_coordinates(hospital_sel)[2])
    ),
    profile = "driving-car",
    output = "sf",
    api_key = api_key
  )

  route_p <- openrouteservice::ors_directions(
    coordinates = list(
      c(lon, lat),
      c(st_coordinates(policia_sel)[1], st_coordinates(policia_sel)[2])
    ),
    profile = "driving-car",
    output = "sf",
    api_key = api_key
  )

  list(
    hospital = list(route = route_h, destino = hospital_sel),
    policia  = list(route = route_p, destino = policia_sel)
  )
}
