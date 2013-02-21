/****************************************
THIS SCRIPT IS CURRENTLY INCOMPLETE.
****************************************/
SET search_path = public;

--CREATE DDL FOR STORAGE BY HSTORE;
DROP FUNCTION IF EXISTS sql_store_by_hstore(boolean);
CREATE FUNCTION sql_store_by_hstore(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN	
	sql := '
		CREATE TABLE by_hstore (
			LIKE geoheader,
			estimate hstore,
			moe hstore,
			PRIMARY KEY (stusab, logrecno)
		)
		WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);
		';
	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;
/*by_hstore created with autovacuum off. Enable with:
ALTER TABLE by_hstore SET (autovacuum_enabled = TRUE, toast.autovacuum_enabled = TRUE);
*/

/********************************************************************
Currently editing this function
*********************************************************************/

/*CREATE TABLE appears above. Table should be populated first with
geoheader data using 

SELECT sql_parse_tmp_geoheader(TRUE, 'by_hstore');

This function adds data to columns with UPDATE statements.*/

DROP FUNCTION IF EXISTS sql_insert_into_hstore(boolean);
CREATE FUNCTION sql_insert_into_hstore(exec boolean = FALSE) RETURNS text AS $function$
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
	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

