
# Code to exclude radar tracks that start outside of the area of interest

# read in polygon showing area of inclusion

aoi <- st_read("P:/312202_visavis/WP2/Previous_radar_migration/GIS/radar_inclusion_poly.shp")

# create separate spatial object with just start points

track_start <- st_as_sf(lwgeom::st_startpoint(test_tracks)) # make spatial object

track_start <- cbind(track_start,test_tracks$id) # add id fields

# check if start point falls within aoi polygon

point_aoi <- as.data.frame(t(st_contains(aoi,track_start, sparse = FALSE)))

track_start <- cbind(track_start,point_aoi) # create table with start points

# add exclusion field to track table

test_tracks <- cbind(test_tracks,track_start$V1)

test_tracks <- test_tracks %>%
  rename(include = track_start.V1)

# create table of tracks to include

include_tracks <- test_tracks %>%
  filter(include == 'TRUE')

mapview(include_tracks) + aoi


rm(point_aoi,test_tracks,track_start)