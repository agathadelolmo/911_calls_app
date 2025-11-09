
library(RSelenium)
library(XML)

eCaps <- list(
  "moz:firefoxOptions" = list(args = list("--headless"))
)

rD <- rsDriver(browser = "firefox",
               geckover = "latest",
               iedrver = NULL,
               chromever = NULL,
               phantomver = NULL,
               extraCapabilities = eCaps,
               port = as.integer(runif(1, 4000, 8000))  # puerto aleatorio
)

driver <- rD[["client"]]

driver$navigate("https://www.monroecounty.gov")

Sys.sleep(0.5)

menu_button <- driver$findElement(using = "css", "#nav-menu")

menu_button$clickElement()

Sys.sleep(0.5)

link_911 <- driver$findElement(using = "xpath", '//a[contains(text(),"911")]')
link_911$clickElement()

Sys.sleep(0.5)

live911_button <- driver$findElement(using = "xpath", '//a[contains(text(), "Live 911 Incidents")]')
live911_button$clickElement()

Sys.sleep(0.5)

refresh_button <- driver$findElement(using = "css", "#refresh-now")
refresh_button$clickElement()

Sys.sleep(0.5)

tbody_element <- driver$findElement(using = "css", "tbody")
html_content <- tbody_element$getElementAttribute("outerHTML")[[1]]

driver$close()
rD[["server"]]$stop()


library(rvest)
library(dplyr)
library(purrr)
library(sf)

tabla <- read_html(html_content) |>
  html_elements("tr") |>
  map_dfr(function(tr) {
    c1 <- tr %>% html_element("td:nth-child(1)")
    tipo <- c1 %>% html_element("div:nth-child(1)") %>% html_text(trim = TRUE)
    direccion <- c1 %>% html_element("div:nth-child(2)") %>% html_text(trim = TRUE)
    codigo <- c1 %>% html_element(".incident911-no") %>% html_text(trim = TRUE)

    c2 <- tr %>% html_element("td:nth-child(2)")
    estado <- c2 %>% html_element("div:nth-child(1)") %>% html_text(trim = TRUE)
    hora <- c2 %>% html_element("div:nth-child(2)") %>% html_text(trim = TRUE)

    tibble(tipo, direccion, codigo, estado, hora)
  })



library(readxl)
library(epitools)
library(stringr)

tabla_geo <- tabla %>%
  mutate(direccion = str_extract(direccion, "^[^:]+"),
         direccion = paste0(direccion, " - Monroe County NY")) %>%
  slice(1:10)

calls_crds_arcgis <- tidygeocoder::geocode(tabla_geo, address = direccion, method = "arcgis")

calls_sf <- sf::st_as_sf(calls_crds_arcgis, coords=c("long","lat"), crs=4326, na.fail=F)

calls_sf <- calls_sf %>%
  filter(!is.na(geometry)) %>%
  mutate(direccion = gsub(" - Monroe County NY", "", direccion),
         hora_txt = substr(hora, 7, 11),
         hora_original = hora,
         hora = format(strptime(hora_txt, "%H:%M"), "%H:%M"),
         fecha = as.Date(paste0(substr(hora_original, 1, 5), "/", format(Sys.Date(), "%Y")),
                         format = "%d/%m/%Y")
  ) %>%
  select(-hora_txt, -hora_original)

bbox_ny <- c(ymin = 43.05, xmin = -77.95, xmax = -77.40, ymax = 43.35)
bbox_ny <- st_as_sfc(st_bbox(bbox_ny, crs = 4326))

calls_sf <- calls_sf[st_within(calls_sf, bbox_ny, sparse = FALSE), ]

calls_sf <- calls_sf %>%
  mutate(estado = case_when(
    estado == "WAITING" ~ "🔴 ESPERANDO",
    estado == "DISPATCHED" ~ "🟠 ENVIADO",
    estado == "ENROUTE" ~ "🟡 EN RUTA",
    estado == "ONSCENE" ~ "🟢 EN ESCENA"
  ))

saveRDS(calls_sf, "calls_sf.rds")
message("Scraping completado y guardado en calls_sf.rds")
