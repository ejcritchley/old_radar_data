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

con <- dbConnect(RPostgres::Postgres(), 
                 host="ninradardata01.nina.no", 
                 dbname="robinv216_kleive",
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

# database = robinv216_kleive

robin_query = 
  st_read(con, 
          query = 
            "SELECT * FROM m201609.track 
       WHERE timestamp_start > '2016-09-02 11:00:00'
       AND timestamp_end < '2016-09-02 13:00:00';",
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

# Create a radius around the radar location 

radar_location = 
  st_read(con, 
          query = 
            "SELECT * FROM m202210.radar 
       WHERE location_name = 'Fedje'
       AND timestamp = '2022-10-03 13:43:20.306';",
          geometry_column = 'position'
  )

mapview(st_zm(radar_location))

radar_location <- st_zm(radar_location)


# Create radar inclusion zone

## Projections
wgs84_epsg <- 4326 
loc_epsg <- 25833

## Radar coordinates [degrees]
radar_lon <- 4.185345
radar_lat <- 52.427827
radar <- st_sfc(st_point(c(radar_lon, radar_lat)),crs=wgs84_epsg)

#OR 

radar <- radar_location

radar_utm <-st_transform(radar_location, crs = loc_epsg)

## Set the minimum and maximum distance from the radar for reliable bird detection
mind <- 100 ## [metres]
maxd <- 5000 ## [metres]

min_buffer <- st_buffer(radar_utm, dist = 10)

max_buffer <- st_buffer(radar_utm, dist = 5000)

mapview(radar_utm) + min_buffer + max_buffer

# polygons to exclude for noise

noise_poly <- st_read("P:/312202_visavis/WP2/Previous_radar_migration/GIS/radar_inclusion_zone.shp")

noise_poly_utm <- st_transform(noise_poly, crs = loc_epsg)

mapview(noise_poly_utm)

aoi <- st_difference(max_buffer, min_buffer)

mapview(aoi)

noise_poly_utm <- st_union(noise_poly_utm)

aoi2 <- st_difference(aoi, noise_poly_utm)

mapview(aoi2)

## Two corners of the radar window are unavailable in our data
## The corner of the radar window the turbine blocks the radar
## The corner of overlap between the horizontal and vertical radar (data contains horizontal-only tracks)
blocked_corners <- rbind(c(287,30),
                         c(115,135))


## The radar is situated within a wind farm
## Wind farm name (for coordinate extraction from main file)
location <- 'Fedje'

# Load some sample Fedge tracks

test_tracks = 
  st_read(con, 
          query = 
            "WITH transformed_tracks AS (
            SELECT *,
            ST_Transform(trajectory, 25833) as trajectory_utm
            FROM m202210.track),
            modified_tracks AS (
            SELECT *,
            ST_Length(trajectory_utm) as track_length, 
      	    ST_Distance(ST_StartPoint(trajectory_utm),
	          ST_EndPoint(trajectory_utm)) as track_distance
            FROM transformed_tracks 
       WHERE timestamp_start > '2022-10-10 09:00:00'
       AND timestamp_end < '2022-10-10 14:00:00'
       AND avg_rcs > -40
       AND avg_rcs < 0
       AND score > 0.85
       AND airspeed > 5
       AND airspeed < 30
       AND classification_id BETWEEN '6' AND '10'),
	tortuosity_table as (
select
	*,
	track_distance / track_length as tortuosity
from
	modified_tracks
)
select
	*
from
	tortuosity_table
where
	tortuosity > 0.65;",
          geometry_column = 'trajectory_utm')


mapview(test_tracks)

test_tracks_utm <- st_transform(test_tracks, crs = loc_epsg)
# 
# test_tracks_utm$start_point <- lwgeom::st_startpoint(test_tracks_utm)
# 
# test_tracks_utm$start_point <- st_transform(test_tracks_utm$start_point, crs = loc_epsg)
# 
# mapview(test_tracks_utm$start_point)
# 
# mapview(test_tracks_utm)

# filter tracks over 200 metres 

test_tracks_utm <- test_tracks_utm %>%
  mutate(start_point = lwgeom::st_startpoint(test_tracks_utm), 
         end_point = lwgeom::st_endpoint(test_tracks_utm),
         track_length_m = as.numeric(st_length(trajectory)),
         track_time = as.numeric(hms::as_hms(difftime(
           time1 = timestamp_end,
           time2 = timestamp_start,
           units = "secs")))
  )

test_tracks_utm <- test_tracks_utm %>%
  filter(track_length_m > 200) %>%
  filter(track_time > 20)

mapview(test_tracks_utm)



# check if line starts outside the area of inclusion

mapview(aoi2)

# create seperate object with just start points

track_start <- st_as_sf(test_tracks_utm$start_point)

track_start <- cbind(track_start,test_tracks_utm$id)

mapview(track_start) + aoi2

# check if start falls within polygon

point_aoi <- as.data.frame(t(st_contains(aoi2,track_start, sparse = FALSE)))

track_start <- cbind(track_start,point_aoi) # create table

track_exclude <- track_start %>%  # filter points outside polygon
  filter(V1 == 'FALSE')

mapview(track_exclude) + aoi2

# create table of points outside the polygon

track_exclude_table <- track_exclude %>%
  select(test_tracks_utm.id, V1)
  rename(id = test_tracks_utm.id, in_polygon = v1) 

track_exclude_table <- cbind(track_exclude$test_tracks_utm.id, track_exclude$V1)

# add exclusion field to track table

test_tracks_utm2 <- cbind(test_tracks_utm,track_start$V1)

exclude_tracks <- test_tracks_utm2 %>%
  filter(track_start.V1 == 'FALSE')

mapview(exclude_tracks) + aoi2

# create table of tracks to include

include_tracks <- test_tracks_utm2 %>%
  filter(track_start.V1 == 'TRUE')

mapview(include_tracks, color = 'green', col.regions = ) + exclude_tracks  + aoi2

mapview(include_tracks) + aoi2




