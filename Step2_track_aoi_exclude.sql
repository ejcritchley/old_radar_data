-- Step 1: Extract the start points of the tracks and add their IDs
WITH track_start AS (
    SELECT 
        track.id AS track_id,
        ST_StartPoint(track.trajectory_utm) AS start_point -- Extracting start points as geometry
    FROM m202210.filtered_tracks AS track
),
-- Step 2: Check if start points fall within the AOI polygon
track_within_aoi AS (
    SELECT 
        ts.track_id,
        ts.start_point,
        ST_Within(ts.start_point, aoi.geom) AS is_within_aoi -- Check if start point is within AOI
    FROM track_start AS ts
    JOIN aoi ON ST_Within(ts.start_point, aoi.geom)
),
-- Step 3: Add inclusion field to the test_tracks table
track_with_inclusion AS (
    SELECT 
        tt.*,
        tw.is_within_aoi AS include -- Add inclusion flag to test_tracks
    FROM test_tracks AS tt
    LEFT JOIN track_within_aoi AS tw ON tt.id = tw.track_id
)
-- Step 4: Filter tracks that should be included (where inclusion flag is TRUE)
SELECT 
    track_with_inclusion.*
FROM track_with_inclusion
WHERE track_with_inclusion.include = TRUE;
