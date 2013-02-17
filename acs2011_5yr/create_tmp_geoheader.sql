DROP TABLE IF EXISTS tmp_geoheader;
CREATE TABLE tmp_geoheader (
	all_fields varchar
)
WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE)
;
