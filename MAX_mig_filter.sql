create or replace
view m202210.Fedje_filtered_tracks as 
with modified_tracks as (
select
	*,
	ST_Length(trajectory) as track_length, 
	ST_Distance(ST_StartPoint(trajectory),
	ST_EndPoint(trajectory)) as track_distance
from
	m202210.track
where
	classification_id in (6, 7, 8, 9, 10)
	and 
avg_rcs > -40
	and avg_rcs < 0
	and 
score > 0.85
	and 
airspeed > 5
	and airspeed < 30
	),
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
	tortuosity > 0.65
	and
	tortuosity < 0.85

