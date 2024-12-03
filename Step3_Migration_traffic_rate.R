
# 02-12-2024

# Calulate the migration traffic rate from tracks filtered for migration
# This is based o the approach by Braderic 2024

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


# need to iterate this per hour?


# find midpoint of all migration tracks

mid_point <- st_as_sf(st_line_interpolate(st_as_sfc(st_zm(include_tracks)), 0.5))

# check if midpoint is within the aoi

midpoint_aoi <- as.data.frame(t(st_contains(aoi,mid_point, sparse = FALSE)))

mid_point <- cbind(mid_point,midpoint_aoi) # create table with start points

# add exclusion field to track table

include_tracks <- cbind(include_tracks,mid_point$V1)

include_tracks <- include_tracks %>%
  rename(include_mid = mid_point.V1)

# create table of tracks to include

include_tracks_v2 <- include_tracks %>%
  filter(include_mid == 'TRUE')

# Set up variables

Pi <- count(mid_point)

rph <- 3600 # number of rotations per hour

Pt <- Pi$n/rph # calculate the mean number of tracks per rotation

A <- st_area(aoi) # get area of radar area of inclusion in Km2

units(A) <- "km^2"

d <- Pt/A # calculate mean bird track density

Vg <- mean(test_tracks$airspeed) # get mean airspeed of tracks

MTR <- d*Vg # calculate migration traffic rate
  

# More streamlined way of doing this
  
A <- st_area(aoi) # get area of radar area of inclusion in Km2

units(A) <- "km^2"

# Summarise values per hour

migration_summary <- st_zm(include_tracks) %>%
  group_by(time=floor_date(timestamp_start, '1 hour')) %>%
  summarise(n_tracks = as.numeric(n()),
            rph = 3600,
            Vg = mean(airspeed),
            Area = A) %>%
  mutate(Pt = n_tracks/rph) %>%
  mutate(d = Pt/Area) %>%
  mutate(MTR = d*Vg)

# Summarise values per hour - option 2 using just track density

migration_summary_v2 <- st_zm(include_tracks_v2) %>%
  group_by(time=floor_date(timestamp_start, '1 hour')) %>%
  summarise(n_tracks = as.numeric(n()),
            rph = 3600,
            Vg = mean(airspeed),
            Area = A) %>%
  mutate(d = n_tracks/Area) %>%
  mutate(MTR = d*Vg) %>%
  mutate(hour = format(as.POSIXct(time), format = "%H:%M"))

# Summarise values per hour - option 3 using number of points per track

migration_summary_v3 <- st_zm(include_tracks_v2) %>%
  group_by(time=floor_date(timestamp_start, '1 hour')) %>%
  summarise(n_tracks = as.numeric(n()),
    n_track_points = as.numeric(sum(nr_of_plots)),
            rph = 3600,
            Vg = mean(airspeed),
            Area = A) %>%
  mutate(Pt = n_track_points/rph) %>%
  mutate(d = Pt/Area) %>%
  mutate(MTR = d*Vg) %>%
  mutate(hour = format(as.POSIXct(time), format = "%H:%M"))


# test plot

plot(migration_summary_v2$time,migration_summary_v2$MTR)

plot(migration_summary_v3$time,migration_summary_v3$MTR)


plot(migration_summary_v3$time,migration_summary_v3$n_tracks)

# plot MTR

g <- ggplot(data = migration_summary_v2) +
  geom_col(time,MTR)

g


