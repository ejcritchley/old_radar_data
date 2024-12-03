
# Calulate the migration traffic rate from tracks filtered for migration
# This is based o the approach by Braderic 2024

# need to iterate this per hour?


# find midpoint of all migration tracks

mid_point <- st_as_sf(st_line_interpolate(st_as_sfc(st_zm(include_tracks)), 0.5))

Pi <- count(mid_point)

rph <- 3600 # number of rotations per hour

Pt <- Pi$n/rph # calculate the mean number of tracks per rotation

A <- st_area(aoi) # get area of radar area of inclusion in Km2

units(A) <- "km^2"

d <- Pt/A # calculate mean bird track density

Vg <- mean(test_tracks$airspeed) # get mean airspeed of tracks

MTR <- d*Vg # calculate migration traffic rate
  

  
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

# Summarise values per hour - option 2

migration_summary_v2 <- st_zm(include_tracks) %>%
  group_by(time=floor_date(timestamp_start, '1 hour')) %>%
  summarise(n_tracks = as.numeric(n()),
            rph = 3600,
            Vg = mean(airspeed),
            Area = A) %>%
  mutate(d = n_tracks/Area) %>%
  mutate(MTR = d*Vg) %>%
  mutate(hour = format(as.POSIXct(time), format = “%H:%M”))


plot(migration_summary_v2$time,migration_summary_v2$MTR)


# plot MTR

g <- ggplot(data = migration_summary_v2) +
  geom_col(time,MTR)

g


