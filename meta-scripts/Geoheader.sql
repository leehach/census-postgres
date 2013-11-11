SET search_path = public;

--CREATE SQL STATEMENT TO CREATE geoheader
DROP FUNCTION IF EXISTS sql_create_geoheader(boolean);
CREATE FUNCTION sql_create_geoheader(exec boolean = FALSE) RETURNS text AS $function$
DECLARE
	sql TEXT;
BEGIN
	SELECT array_to_string(array_agg(sql_statement), '') INTO sql
	FROM (
		SELECT
			CASE WHEN line_number = 1 THEN E'CREATE TABLE geoheader (\n' ELSE '' END ||
				E'\t' || name || ' ' ||
			CASE WHEN name IN ('sumlevel', 'logrecno') THEN 'int'
				ELSE 'varchar(' || field_size || ')'
			END || E',\n' ||
			CASE WHEN line_number = max(line_number) OVER () THEN 
				E'\tPRIMARY KEY (stusab, logrecno)\n);' 
				ELSE '' 
			END
			AS sql_statement
		FROM
			geoheader_schema
		ORDER BY
			line_number
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

--ADD COMMENTS TO COLUMNS OF geoheader
DROP FUNCTION IF EXISTS sql_geoheader_comments(boolean);
CREATE FUNCTION sql_geoheader_comments(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
	row RECORD;
BEGIN
	
	FOR row IN SELECT * FROM geoheader_schema LOOP
		sql := sql || 'COMMENT ON COLUMN geoheader.' || row.name || ' IS ' || quote_literal(COALESCE(row.descr, row.sumlevels, '')) || E';\n';
	END LOOP;

	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

--CREATE SQL STATEMENT TO PARSE tmp_geoheader INTO PERMANENT TABLE
--To Do: Allow target table to depend upon store_by method
DROP FUNCTION IF EXISTS sql_parse_tmp_geoheader(boolean, text);
CREATE FUNCTION sql_parse_tmp_geoheader(exec boolean = FALSE, target text = 'geoheader') RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
	insert_list TEXT := '';
	values_list TEXT := '';
	row RECORD;
BEGIN	
	sql := 'INSERT INTO ' || target || E' SELECT\n';
	FOR row IN SELECT *, max(line_number) OVER () AS max_line_number FROM geoheader_schema LOOP
		insert_list := insert_list || E'\t' || row.name; 
		values_list := values_list || E'\t';
		IF row.line_number > 5 THEN values_list := values_list || 'NULLIF('; END IF;
		values_list := values_list || 'btrim(substring(all_fields from ' || row.starting_position || ' for ' || row.field_size || '))';
		IF row.name IN ('sumlevel', 'sumlev', 'logrecno') THEN values_list := values_list || '::int'; END IF;
		IF row.line_number > 5 THEN values_list := values_list || E', \'\')'; END IF;
		values_list := values_list || ' AS ' || row.name;
		IF row.line_number < row.max_line_number THEN 
			insert_list := insert_list || ','; 
			values_list := values_list || ','; 
		END IF;
		insert_list := insert_list || E'\n';
		values_list := values_list || E'\n'; 
	END LOOP;

	sql := 'INSERT INTO ' || target || E'(\n' || insert_list || E')\nSELECT\n' || values_list || 'FROM tmp_geoheader;';

	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;
