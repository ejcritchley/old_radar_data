WITH track_summary AS (
    -- Step 1: Group by hourly time intervals and summarize the data
    SELECT
        -- Group by floor of timestamp_start to get the hour
        DATE_TRUNC('hour', timestamp_start) AS time,
        COUNT(*) AS n_tracks,          -- Count of tracks
        3600 AS rph,                  -- rph value is constant (3600 seconds per hour)
        AVG(airspeed) AS Vg,          -- Average airspeed
        (SELECT ST_Area(aoi.geom) / 1000000 FROM aoi) AS Area  -- Area in square kilometers (same as before)
    FROM include_tracks
    GROUP BY DATE_TRUNC('hour', timestamp_start)
),
-- Step 2: Calculate additional metrics
track_metrics AS (
    SELECT
        time,
        n_tracks,
        rph,
        Vg,
        Area,
        -- Step 3: Calculate the density (d) and MTR
        n_tracks / Area AS d,            -- Density
        (n_tracks / Area) * Vg AS MTR,   -- MTR (Migration Traffic Rate)
        -- Step 4: Extract hour in HH:MM format
        TO_CHAR(time, 'HH24:MI') AS hour
    FROM track_summary
)
-- Final selection of results
SELECT * FROM track_metrics;
