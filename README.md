# old_radar_data

This repository is for the processing and analysis of old avian radar data to collect metrics on bird migration rates. 

# Data processing steps

1. Calculate additional track parameters and apply filters
2. Create polygon for area of inclusion
3. Remove tracks that start outside the area of inclusion
4. Calculate the migration traffic rate (MTR) per hour

# Content

Postgresql-scripts for processing the radar data to extract migration tracks and migration rates
- Fedje_2022_migration - test script for accessing the MAX radar data collected at Fedje in 2022

R-scripts for interaction with the database
- Radar_data_connect - for initial connection to the radar databases
- Step2_track_aoi_exclude - for removing tracks that start outside the area of includion
- Step3_Migration_traffic_rate - for calculating the MTR from the filtered tracks
