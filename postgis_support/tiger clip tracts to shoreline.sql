--Create table to hold shoreline and major bodies of internal water.
--This is exactly the same as tiger_areawater_2010.

-- DROP TABLE geo_water.tiger_shoreline_2010;
CREATE TABLE geo_water.tiger_shoreline_2010
(
  gid serial NOT NULL,
  statefp character varying(2),
  countyfp character varying(3),
  ansicode character varying(8),
  hydroid character varying(22),
  fullname character varying(100),
  mtfcc character varying(5),
  aland double precision,
  awater double precision,
  intptlat character varying(11),
  intptlon character varying(12),
  geom geometry(MultiPolygon,4269),
  CONSTRAINT tiger_shoreline_2010_pkey PRIMARY KEY (gid )
);

-- DROP INDEX geo_water.tiger_shoreline_2010_geom_gist;
CREATE INDEX tiger_shoreline_2010_geom_gist
  ON geo_water.tiger_shoreline_2010
  USING gist
  (geom );

--Eliminate "island" water features, e.g. inland ponds, lakes, and streams.
--Insert shoreline and major inland water features into new table.
INSERT INTO geo_water.tiger_shoreline_2010
SELECT * FROM geo_water.tiger_areawater_2010 WHERE gid IN (
	SELECT DISTINCT unnest(array[a.gid, b.gid]) AS gid
	FROM geo_water.tiger_areawater_2010 a JOIN geo_water.tiger_areawater_2010 b 
		ON (ST_Intersects(a.geom, b.geom) AND a.gid < b.gid)
	)
;

--Clip existing tract geometries to eliminate water features.
UPDATE acs2010_5yr.geoheader g
SET geom = ST_Difference(g.geom, w2.geom)
FROM (
	SELECT stusab, logrecno, ST_Collect(w1.geom) AS geom
	FROM acs2010_5yr.geoheader g JOIN (
		SELECT statefp AS state, countyfp AS county, (ST_Dump(geom)).geom AS geom
		FROM geo_water.tiger_shoreline_2010
		WHERE statefp != '02'
		) w1 USING (state, county)
	WHERE ST_Intersects(g.geom, w1.geom) 
	GROUP BY stusab, logrecno
	) w2
WHERE g.stusab = w2.stusab and g.logrecno = w2.logrecno
;