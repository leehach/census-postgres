/****************************************
THIS SCRIPT IS CURRENTLY INCOMPLETE.
****************************************/
SET search_path = public;

--NEED TO TURN INTO A FUNCTION TO BE CONSISTENT WITH REMAINDER OF PROJECT
--CREATE DDL FOR STORAGE BY HSTORE;
--DROP TABLE IF EXISTS by_hstore ;
CREATE TABLE by_hstore (
	LIKE geoheader,
	estimate hstore,
	moe hstore,
	PRIMARY KEY (stusab, logrecno)
)
WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);
/*by_hstore created with autovacuum off. Enable with:
ALTER TABLE by_hstore SET (autovacuum_enabled = TRUE, toast.autovacuum_enabled = TRUE);
*/

--CREATE DDL FOR STORAGE BY hstore
--Hstore table is simple to declare. DDL is in Create Data Tables SQL script.
DROP FUNCTION IF EXISTS sql_insert_into_hstore();
CREATE FUNCTION sql_insert_into_hstore() RETURNS text AS $function$
BEGIN

	SELECT
		CASE WHEN seq_position = 1 THEN
			'UPDATE by_hstore SET estimate = ARRAY['
			ELSE ''
		END || 
		E'\tNULLIF(NULLIF(' || cell_id || E', \'\'), \'.\')::double precision' ||
		CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq) THEN
			E'\n] FROM tmp_' || seq_id || ' t WHERE stusab = t.stusab AND logrecno = t.logrecno;'
			ELSE ','
		END AS sql_statement
	FROM
		vw_cell
	ORDER BY seq, seq_position
	;
END;
$function$ LANGUAGE plpgsql;

