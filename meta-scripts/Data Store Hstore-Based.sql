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
	sql := $$
		CREATE TABLE by_hstore (
			LIKE geoheader,
			estimate hstore NOT NULL DEFAULT hstore('',''),
			moe hstore NOT NULL DEFAULT hstore('',''),
			PRIMARY KEY (stusab, logrecno)
		)
		WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);
		$$;
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
DECLARE
	sql TEXT := '';
BEGIN
	SELECT array_to_string(array_agg(sql_statement), E'\n') INTO sql
	FROM (
		SELECT
			CASE WHEN seq_position = 1 THEN
				'UPDATE by_hstore SET estimate = estimate || '
				ELSE ''
			END || 
			E'\tCASE WHEN ' || cell_id || E' IS NULL THEN \'\' ELSE hstore(' || quote_literal(cell_id) || ', ' || cell_id || ') END ' ||
			CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq) THEN
				E'\nFROM tmp_' || seq_id || ' t WHERE by_hstore.stusab = upper(t.stusab) AND by_hstore.logrecno = t.logrecno;'
				ELSE '||'
			END AS sql_statement
		FROM
			vw_cell
		ORDER BY seq, seq_position
		) s
	;
	
	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

