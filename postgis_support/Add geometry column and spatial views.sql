--Requires PostGIS Extension!

SET search_path = <schema>, public; --Set desired target schema here

CREATE SEQUENCE geoheader_gid_seq;
ALTER TABLE geoheader 
	ADD COLUMN geom geometry(MultiPolygon, 4269),
	ADD COLUMN gid int NOT NULL DEFAULT nextval('geoheader_gid_seq');
CREATE INDEX ON geoheader USING gist (geom);

--Add spatial layers for some common Census geographies.
--Assumes spatial tables have names matching filename from Census FTP site.

--States (sumlevel = 40 or '040')
--Import tl_2010_us_state10 with shp2pgsql
UPDATE geoheader g
SET geom = t.geom
FROM tl_2010_us_state10 t
WHERE g.sumlevel = 40 AND split_part(g.geoid, 'US', 2) = t.geoid10
;

--Needs gid above
CREATE OR REPLACE VIEW geo_state AS
SELECT 
	gid,
	geoid,
	name,
	geom
FROM geoheader
WHERE sumlevel = 40 and component = '00'
;

--Counties (sumlevel = 50 or '050')
--Import tl_2010_us_county10 with shp2pgsql
UPDATE geoheader g
SET geom = t.geom
FROM tl_2010_us_county10 t
WHERE g.sumlevel = 50 AND split_part(g.geoid, 'US', 2) = t.geoid10
;

--Tracts (sumlevel = 140)
--Import tl_2010_*_tract10 by state with shp2pgsql
UPDATE geoheader g
SET geom = t.geom
FROM tl_2010_us_tract10 t
WHERE g.sumlevel = 140 AND split_part(g.geoid, 'US', 2) = t.geoid10
;
