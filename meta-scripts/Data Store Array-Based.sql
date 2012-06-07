/****************************************
THIS SCRIPT IS CURRENTLY INCOMPLETE.
****************************************/
SET search_path = public;

--CREATE DDL FOR STORAGE BY ARRAY COLUMNS
DROP FUNCTION IF EXISTS sql_store_by_array_columns(boolean);
CREATE FUNCTION sql_store_by_array_columns(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN	
	SELECT array_to_string(array_agg(sql_statement), '') INTO sql 
	FROM (
		SELECT 
			CASE WHEN seq = 1 THEN E'CREATE TABLE by_arrays (\n\tLIKE geoheader,\n' ELSE '' END ||
			E'\t' || seq_id || E' double precision[],\n' ||
			CASE WHEN seq = max(seq) OVER ()
				THEN E'\tPRIMARY KEY (stusab, logrecno)\n)\nWITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);\n'
				ELSE ''
			END AS sql_statement
		FROM vw_sequence 
		ORDER BY seq
		) s
	;

	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

/********************************************************************
Currently editing this function
*********************************************************************/

/*CREATE TABLE appears above. Table should be populated first with
geoheader data using 

SELECT sql_parse_tmp_geoheader(ARRAY[TRUE], 'by_arrays');

This function adds data to columns with UPDATE statements.*/
DROP FUNCTION IF EXISTS sql_insert_into_array_columns(boolean);
CREATE FUNCTION sql_insert_into_array_columns(exec boolean = FALSE) RETURNS text AS $function$
DECLARE
	sql TEXT := '';
BEGIN
	SELECT array_to_string(array_agg(sql_statement), E'\n') INTO sql
	FROM (
		SELECT
			CASE WHEN seq_position = 1 THEN
				'UPDATE by_arrays SET ' || seq_id || ' = ARRAY['
				ELSE ''
			END || 
			E'\tNULLIF(NULLIF(' || cell_id || E', \'\'), \'.\')::double precision' ||
			CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq) THEN
				E'\n] FROM tmp_' || seq_id || ' t WHERE by_arrays.stusab = upper(t.stusab) AND by_arrays.logrecno = t.logrecno;'
				ELSE ','
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
