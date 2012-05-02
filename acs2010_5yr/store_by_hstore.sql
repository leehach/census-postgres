--CREATE DDL FOR STORAGE BY HSTORE;
--DROP TABLE IF EXISTS by_hstore ;
CREATE TABLE by_hstore (
	LIKE geoheader,
	estimate hstore,
	moe hstore,
	PRIMARY KEY (stusab, logrecno)
)
WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);

