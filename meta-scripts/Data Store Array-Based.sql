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
			CASE WHEN seq = min(seq_position) OVER (PARTITION BY seq) THEN E'CREATE TABLE by_arrays (\n\tLIKE geoheader,\n' ELSE '' END ||
			E'\t' || seq_id || E' double precision[],\n' ||
			CASE WHEN seq = max(seq) OVER ()
				THEN E'\tPRIMARY KEY (stusab, logrecno)\n)\nWITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);\n'
				ELSE ''
			END AS sql_statement
		FROM vw_sequence 
		ORDER BY seq
		) s
	;

	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

/********************************************************************
Currently editing this function
*********************************************************************/

/*CREATE TABLE appears above. Table should be populated first with
geoheader data using 

SELECT sql_parse_tmp_geoheader(TRUE, 'by_arrays');

This function adds data to columns with UPDATE statements.*/
DROP FUNCTION IF EXISTS sql_insert_into_array_columns(boolean);
CREATE FUNCTION sql_insert_into_array_columns(exec boolean = FALSE) RETURNS text AS $function$
DECLARE
	sql TEXT := '';
BEGIN
	SELECT array_to_string(array_agg(sql_statement), E'\n') INTO sql
	FROM (
		SELECT
			CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN
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

	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_view_estimate_stored_by_array_columns(boolean);
CREATE FUNCTION sql_view_estimate_stored_by_array_columns(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN	
	SELECT array_to_string(array_agg(sql_statement), E'\n') INTO sql 
	FROM (
		SELECT 
			seq,
			CASE WHEN table_position = 1 THEN 'CREATE VIEW ' || table_id || E' AS SELECT \n'
				|| E'\tstusab, logrecno,\n' 
				ELSE ''
			END || 
			E'\t' || seq_id || '[' || seq_position || ']' || ' AS ' || cell_id || 
			CASE WHEN table_position = max(table_position) OVER (PARTITION BY table_id)
				THEN E'\nFROM by_arrays;\n'
				ELSE ','
			END AS sql_statement
		FROM vw_cell JOIN (SELECT seq, coverage FROM vw_sequence) s USING (seq)
		WHERE COALESCE(coverage, 'all') != 'pr'
		ORDER BY seq, seq_position
		) s
	;

	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

/*
--Alternate view of estimates. Each subject table is an array column. 
--Too large to do SELECT *, but OK to query specific columns?

		SELECT 
			seq,
			CASE WHEN seq = min(seq_position) OVER (PARTITION BY seq) AND seq_position = 1 THEN E'CREATE VIEW vw_estimate_by_arrays AS SELECT \n'
				|| E'\tstusab, logrecno,\n' 
				ELSE ''
			END || 
			CASE WHEN table_position = 1
				THEN 'ARRAY['
				ELSE ''
			END ||
			E'\t' || seq_id || '[' || seq_position || ']' ||
			CASE WHEN table_position = max(table_position) OVER (PARTITION BY table_id)
				THEN E'\n\t] AS ' || table_id ||
				CASE WHEN seq = max(seq) OVER ()  
					THEN E'\nFROM by_arrays;\n'
					ELSE ','
				END
				ELSE ','
			END AS sql_statement
		FROM vw_cell JOIN (SELECT seq, coverage FROM vw_sequence) s USING (seq)
		WHERE COALESCE(coverage, 'all') != 'pr'
		ORDER BY seq, seq_position

*/