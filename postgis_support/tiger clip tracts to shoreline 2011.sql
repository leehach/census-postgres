--Create table to hold shoreline and major bodies of internal water.
--This is exactly the same as tiger_areawater_2010.

-- DROP TABLE geo_water.tiger_shoreline_2011;
CREATE TABLE geo_water.tiger_shoreline_2011
(
	LIKE geo_water.tiger_areawater_2011,
	PRIMARY KEY (gid )
);

-- DROP INDEX geo_water.tiger_shoreline_2010_geom_gist;
CREATE INDEX tiger_shoreline_2011_geom_gist
  ON geo_water.tiger_shoreline_2011
  USING gist
  (geom );

--Eliminate "island" water features, e.g. inland ponds, lakes, and streams.
--Insert shoreline and major inland water features into new table.
INSERT INTO geo_water.tiger_shoreline_2011
SELECT * FROM geo_water.tiger_areawater_2011 WHERE gid IN (
	SELECT DISTINCT unnest(array[a.gid, b.gid]) AS gid
	FROM geo_water.tiger_areawater_2011 a JOIN geo_water.tiger_areawater_2011 b 
		ON (ST_Intersects(a.geom, b.geom) AND a.gid < b.gid)
	)
;

--Clip existing tract geometries to eliminate water features.
UPDATE acs2011_5yr.geoheader g
SET geom = ST_Difference(g.geom, w2.geom)
FROM (
	SELECT stusab, logrecno, ST_Collect(w1.geom) AS geom
	FROM acs2011_5yr.geoheader g JOIN (
		SELECT statefp AS state, countyfp AS county, (ST_Dump(geom)).geom AS geom
		FROM geo_water.tiger_shoreline_2011
		WHERE statefp != '02'
		) w1 USING (state, county)
	WHERE ST_Intersects(g.geom, w1.geom) 
	GROUP BY stusab, logrecno
	) w2
WHERE g.stusab = w2.stusab and g.logrecno = w2.logrecno
;