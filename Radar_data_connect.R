# FEDJE RADAR CONNECT
# Connect to the PostgreSQL database containing the MAX Radar data collected on Fedje Island (03-10-2022 - 04.11.2022)

# load packages

library(RPostgreSQL)
library(RPostgres)
library(DBI)
library(tidyverse)
library(sf)
library(mapview)
library(ggplot2)
#library(NinaR)
library(leaflet)

#options(viewer = NULL) 
#mapviewOptions(viewer.suppress=TRUE)

# create connection to the PostgreSQL database
# This code generates a pop-up window to input username and password

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="utsira_max_1",
                 user=rstudioapi::askForPassword("Database username"),
                 password=rstudioapi::askForPassword("Database password"))

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="fugleradar",
                 user=rstudioapi::askForPassword("Database username"),
                 password=rstudioapi::askForPassword("Database password"))

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="robinv216_seljestokken_2019",
                 user=rstudioapi::askForPassword("Database username"),
                 password=rstudioapi::askForPassword("Database password"))

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="robinv216_seljestokken_start",
                 user=rstudioapi::askForPassword("Database username"),
                 password=rstudioapi::askForPassword("Database password"))

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="robinv216_gronegga",
                 user=rstudioapi::askForPassword("Database username"),
                 password=rstudioapi::askForPassword("Database password"))

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="temp_flex",
                 user=rstudioapi::askForPassword("Database username"),
                 password=rstudioapi::askForPassword("Database password"))


# basic functions for exploring the tables in the database

dbListTables(con) #list all the tables

dbListFields(con, "trackestimate") #list the fields in a table

obs <- tbl(con, "observation") #get a reference to a table

dbDisconnect(con) #disconnect from database

# radar tracks are stored in the "track" table
# track annotations & comments are stored in the "observation" table

# link to the track table

track_table <- tbl(con,
                   Id(schema = "robin_radar",
                      table = "tracklines"))  # Fedje track location as of 2023

test <- track_table %>%
  #select(id,timestamp_start,airspeed,trajectory,trajectory_time) %>%
  #filter(timestamp_start > "2022-10-10 09:00:00", timestamp_start < "2022-10-10 09:10:00") %>% 
  head(20) %>%
  collect


#Setting up PostGIS for plotting tracks in mapview

dbSendQuery(con, "CREATE EXTENSION postgis SCHEMA robin_radar;")

#select a small number of tracks to plot

test_query = 
  st_read(con, 
          query = 
            "SELECT * FROM robin_radar.tracklines 
       WHERE start_date > '2014-08-01 08:00:00'
       AND start_date < '2014-08-03 10:00:00';",
          geometry_column = 'geom'
  )


# fugleradar.fuglradar_utm33n = Smøla databases 

# link to the track table

track_table <- tbl(con,
                   Id(schema = "fuglradar_utm33n",
                      table = "merlin_tracklines"))  # Fedje track location as of 2023

test <- track_table %>%
  #select(id,timestamp_start,airspeed,trajectory,trajectory_time) %>%
  #filter(timestamp_start > "2022-10-10 09:00:00", timestamp_start < "2022-10-10 09:10:00") %>% 
  head(20) %>%
  collect


#Setting up PostGIS for plotting tracks in mapview

dbSendQuery(con, "CREATE EXTENSION postgis SCHEMA fuglradar_utm33n;")

#select a small number of tracks to plot

test_query = 
  st_read(con, 
          query = 
            "SELECT * FROM fuglradar_utm33n.merlin_tracklines 
       WHERE date > '2014-05-20'
       AND date < '2014-05-22';",
          geometry_column = 'geom'
  )


map =
  mapview(test_query,
          label = paste0(test_query$classification_id)
  )

map

# link to the track table

points_table <- tbl(con,
                   Id(schema = "fuglradar_utm33n",
                      table = "merlin_trackpoints"))  # Fedje track location as of 2023

test <- points_table %>%
  #select(id,timestamp_start,airspeed,trajectory,trajectory_time) %>%
  #filter(timestamp_start > "2022-10-10 09:00:00", timestamp_start < "2022-10-10 09:10:00") %>% 
  head(20) %>%
  collect


#Setting up PostGIS for plotting tracks in mapview

dbSendQuery(con, "CREATE EXTENSION postgis SCHEMA fuglradar_utm33n;")

#select a small number of tracks to plot

test_query = 
  st_read(con, 
          query = 
            "SELECT * FROM fuglradar_utm33n.merlin_trackpoints 
       WHERE date_l > '2014-05-21 18:00:00'
       AND date_l < '2014-05-21 19:00:00';",
          geometry_column = 'geom'
  )


map =
  mapview(test_query,
          label = paste0(test_query$classification_id)
  )

map

# load radar position

radar_position = 
  st_read(con, 
          query = 
            "SELECT * FROM fuglradar_utm33n.merlin_radar_pos;",
          geometry_column = 'geom'
  )


map_radar_pos =
  mapview(radar_position
  )

map_radar_pos

# load 100 m rings around radar

radar_rings = 
  st_read(con, 
          query = 
            "SELECT * FROM fuglradar_utm33n.merlin_radar_rings;",
          geometry_column = 'geom'
  )


map_radar_rings =
  mapview(radar_rings
  )

map_radar_pos + map_radar_rings


smola_ring = 
  st_read(con, 
          query = 
            "SELECT * FROM fuglradar_utm33n.smola_ring;",
          geometry_column = 'geom'
  )


map_smola_ring =
  mapview(smola_ring
  )

map_radar_pos + map_smola_ring + map_radar_rings


#select a small number of tracks to plot

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM fuglradar_utm33n.robin_tracklines_full 
       WHERE new_date > '2014-03-04 08:00:00'
       AND new_date < '2014-03-04 10:00:00';",
          geometry_column = 'geom'
  )


map =
  mapview(robin_query,
          label = paste0(robin_query$classification_id)
  )

map



# Guleslettene tracks

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="guleslettene_2021",
                 user=rstudioapi::askForPassword("Database username"),
                 password=rstudioapi::askForPassword("Database password"))


#select a small number of tracks to plot

# database = robinv216_seljestokken_2019
# schema = public_18_19

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM public.track 
       WHERE timestamp_start > '2021-11-04 08:00:00'
       AND timestamp_end < '2021-11-04 10:00:00';",
          geometry_column = 'trajectory'
  )


robin_query <- st_zm(robin_query)

map =
  mapview(robin_query,
          label = paste0(robin_query$classification_id)
  )

map

leaflet(map)


write.csv(robin_query, "GUL_test_lines.csv")

saveRDS(robin_query, "GUL_test_lines2.rds")


# Gaulosen tracks

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM m201910.track 
       WHERE timestamp_start > '2019-10-31 13:00:00'
       AND timestamp_end < '2019-10-31 14:00:00'
          AND
          classification_id in (6, 7, 8, 9, 10)
          AND
          score > 0.85
          AND
          airspeed > 5
          AND
          airspeed < 30;",
          geometry_column = 'trajectory'
  )


robin_query <- st_zm(robin_query)

map =
  mapview(robin_query,
          label = paste0(robin_query$classification_id)
  )

map


# database = temp_flex

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM public_21.track 
       WHERE timestamp_start > '2021-04-13 08:00:00'
       AND timestamp_end < '2021-04-13 10:00:00';",
          geometry_column = 'trajectory'
  )


robin_query <- st_zm(robin_query)

map =
  mapview(robin_query,
          label = paste0(robin_query$classification_id)
  )

map

leaflet(map)


# database = robinv216_seljestokken_start

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM public.track 
       WHERE timestamp_start > '2018-10-07 08:00:00'
       AND timestamp_end < '2018-10-07 10:00:00';",
          geometry_column = 'trajectory'
  )


robin_query <- st_zm(robin_query)

map =
  mapview(robin_query,
          label = paste0(robin_query$classification_id)
  )

map

leaflet(map)


# database = robinv216_gronegga

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM public.track 
       WHERE timestamp_start > '2019-04-02 08:00:00'
       AND timestamp_end < '2019-04-02 10:00:00';",
          geometry_column = 'trajectory'
  )


robin_query <- st_zm(robin_query)

map =
  mapview(robin_query,
          label = paste0(robin_query$classification_id)
  )

map

leaflet(map)


# database = merlin_radar

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM merlin_radar.trackpoints 
       WHERE date_l = '2013-08-29 18:19:27';",
          geometry_column = 'geom'
  )


robin_query <- st_zm(robin_query)

map =
  mapview(robin_query,
          label = paste0(robin_query$classification_id)
  )

map

leaflet(map)

