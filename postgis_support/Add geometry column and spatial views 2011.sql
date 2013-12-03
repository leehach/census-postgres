--Requires PostGIS Extension!

SET search_path = acs2011_5yr, public; --Change target schema here if other than acs2011_5yr

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
FROM tl_2011_us_state t
WHERE g.sumlevel = 40 AND split_part(g.geoid, 'US', 2) = t.geoid
;

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
FROM tl_2011_us_county t
WHERE g.sumlevel = 50 AND split_part(g.geoid, 'US', 2) = t.geoid
;

CREATE OR REPLACE VIEW geo_county AS
SELECT 
	gid,
	geoid,
	name,
	geom
FROM geoheader
WHERE sumlevel = 50 and component = '00'
;

--Tracts (sumlevel = 140)
--Import tl_2010_*_tract10 by state with shp2pgsql
UPDATE geoheader g
SET geom = t.geom
FROM tl_2011_us_tract t
WHERE g.sumlevel = 140 AND split_part(g.geoid, 'US', 2) = t.geoid
;

CREATE OR REPLACE VIEW geo_tract AS
SELECT 
	gid,
	geoid,
	name,
	geom
FROM geoheader
WHERE sumlevel = 140 and component = '00'
;
