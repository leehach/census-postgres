SET search_path = public;

--CREATE DDL FOR GEOHEADER IMPORT TABLE
DROP FUNCTION IF EXISTS sql_create_tmp_geoheader(boolean);
CREATE FUNCTION sql_create_tmp_geoheader(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN
	sql := 'DROP TABLE IF EXISTS tmp_geoheader;
CREATE TABLE tmp_geoheader (
	all_fields varchar
)
WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE)
;';

	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

--CREATE SQL STATEMENT TO IMPORT GEOHEADER TO STAGING TABLE
DROP FUNCTION IF EXISTS sql_import_geoheader(boolean, text[]);
CREATE FUNCTION sql_import_geoheader(exec boolean = FALSE, stusab_criteria text[] = ARRAY['%']) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
	row RECORD;
BEGIN	
	FOR row IN SELECT stusab FROM stusab WHERE stusab ILIKE ANY (stusab_criteria) LOOP
		sql := sql || E'COPY tmp_geoheader FROM \'' || get_census_upload_root() || '/'
			|| current_schema() || '/All_Geographies_Not_Tracts_Block_Groups/g20105'
			|| row.stusab || E'.txt\';\n';
	END LOOP;

	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

--CREATE DDL FOR SEQUENCE IMPORT TABLES
DROP FUNCTION IF EXISTS sql_drop_import_tables(boolean);
CREATE FUNCTION sql_drop_import_tables(exec boolean = FALSE) RETURNS text AS $function$
DECLARE
	sql TEXT := '';
	sql_estimate text;
	sql_moe text;
BEGIN
	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT
			seq,
			'DROP TABLE IF EXISTS tmp_' || seq_id || E';' AS sql1,
			'DROP TABLE IF EXISTS tmp_' || seq_id || E'_moe;' AS sql2
		FROM vw_sequence
		ORDER BY seq
		) s
	;

	sql := sql_estimate || E'\n\n' || sql_moe;
	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_create_import_tables(boolean);
CREATE FUNCTION sql_create_import_tables(exec boolean = FALSE) RETURNS text AS $function$
DECLARE
	sql TEXT := '';
	sql_estimate text;
	sql_moe text;
BEGIN
	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT
			seq,
			CASE WHEN seq_position = 1 THEN
				'CREATE TABLE tmp_' || seq_id || E' (\n'
				|| E'\tfileid varchar(6),\n\tfiletype varchar(6), \n\tstusab varchar(2), \n'
				|| E'\tchariter varchar(3), \n\tseq varchar(4), \n\tlogrecno int,\n' 
				ELSE ''
			END || 
			E'\t' || cell_id || ' varchar' ||
			CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq)
				THEN E'\n)\nWITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);\n'
				ELSE ','
			END AS sql1,
			CASE WHEN seq_position = 1 THEN
				'CREATE TABLE tmp_' || seq_id || E'_moe (\n'
				|| E'\tfileid varchar(6),\n\tfiletype varchar(6), \n\tstusab varchar(2), \n'
				|| E'\tchariter varchar(3), \n\tseq varchar(4), \n\tlogrecno int,\n' 
				ELSE ''
			END || 
			E'\t' || cell_id || '_moe varchar' ||
			CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq)
				THEN E'\n)\nWITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);\n'
				ELSE ','
			END AS sql2
		FROM vw_cell
		ORDER BY seq, seq_position
		) s
	;

	sql := sql_estimate || E'\n\n' || sql_moe;
	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

--CREATE DDL FOR IMPORT (COPY) STATEMENTS
/*
--COPY can be executed with e.g.
SELECT sql_import_sequences(TRUE);

--States can be specified by an array of state codes, including wild cards.
--Sequences can be specified by an array of sequence numbers.
--This imports sequences 1 and 2 for NY and all states that begin with W (WA, WI, WV, WY)
SELECT sql_import_sequences(TRUE, array['ny', 'w%'], array[1, 2]);

--If you specify a state array you must specify a seq array and vice versa.
--To import all states but limit the sequences, use:
SELECT sql_import_sequences(TRUE, array['%'], array[1, 2]);

--To import all sequences but limit the states, use:
SELECT sql_import_sequences(TRUE, array['ny', 'w%'], (SELECT array_agg(seq) FROM vw_sequence));

--More examples (BETWEEN 'a' AND 'm', BETWEEN 1 AND 50, using generate_series()) in import file.
*/
DROP FUNCTION IF EXISTS sql_import_sequences(boolean, text[], int[], text);  
CREATE FUNCTION sql_import_sequences(exec boolean = FALSE, stusab_criteria text[] = ARRAY['%'], 
	seq_criteria int[] = ARRAY[-1], actions text = 'atem'
	) RETURNS text AS $sql_import_sequences$
DECLARE 
	sql TEXT := '';
	bool_large_geo BOOLEAN;
	bool_small_geo BOOLEAN;
	bool_estimate BOOLEAN;
	bool_moe BOOLEAN;
	sql_large_geo TEXT;
	sql_small_geo TEXT;
	sql_large_geo_moe TEXT;
	sql_small_geo_moe TEXT;
	seq_criteria2 int[];
BEGIN	
	IF seq_criteria = ARRAY[-1] THEN 
		seq_criteria2 := (SELECT array_agg(seq) FROM vw_sequence); 
	ELSE
		seq_criteria2 := seq_criteria;
	END IF;
	SELECT 
		array_to_string(array_agg(sql1), E'\n'),
		array_to_string(array_agg(sql2), E'\n'),
		array_to_string(array_agg(sql1_moe), E'\n'),
		array_to_string(array_agg(sql2_moe), E'\n')
	INTO 	sql_large_geo, sql_small_geo, sql_large_geo_moe, sql_small_geo_moe
	FROM (
		SELECT
			'COPY tmp_' || seq_id || E' FROM \''
			|| get_census_upload_root() || '/' || current_schema || '/All_Geographies_Not_Tracts_Block_Groups/e20105'
			|| stusab || lpad(seq::varchar, 4, '0') || E'000.txt\' WITH CSV;'
			AS sql1,
			'COPY tmp_' || seq_id || E' FROM \''
			|| get_census_upload_root() || '/' || current_schema || '/Tracts_Block_Groups_Only/e20105'
			|| stusab || lpad(seq::varchar, 4, '0') || E'000.txt\' WITH CSV;'
			AS sql2,
			'COPY tmp_' || seq_id || E'_moe FROM \''
			|| get_census_upload_root() || '/' || current_schema || '/All_Geographies_Not_Tracts_Block_Groups/m20105'
			|| stusab || lpad(seq::varchar, 4, '0') || E'000.txt\' WITH CSV;'
			AS sql1_moe,
			'COPY tmp_' || seq_id || E'_moe FROM \''
			|| get_census_upload_root() || '/' || current_schema || '/Tracts_Block_Groups_Only/m20105'
			|| stusab || lpad(seq::varchar, 4, '0') || E'000.txt\' WITH CSV;'
			AS sql2_moe
		FROM	stusab, vw_sequence
		WHERE	stusab ILIKE ANY (stusab_criteria) AND seq = ANY (seq_criteria2)
		) s
	;

	--a means All_Geographies_Not_Tracts_Block_Groups
	--t means Tracts_Block_Groups_Only
	--e means Estimates
	--m means Marging of Error
	--Missing a implies t, missing t implies a
	--Missing e implies m, missing m implies e
	bool_large_geo = actions ILIKE '%a%' OR actions NOT ILIKE '%t%'; 
	bool_small_geo = actions ILIKE '%t%' OR actions NOT ILIKE '%a%';
	bool_estimate = actions ILIKE '%e%' OR actions NOT ILIKE '%m%';
	bool_moe = actions ILIKE '%m%' OR actions NOT ILIKE '%e%';
	IF bool_large_geo THEN
		IF bool_estimate THEN sql := sql || sql_large_geo || E'\n\n'; END IF;
		IF bool_moe THEN sql := sql || sql_large_geo_moe || E'\n\n'; END IF;
	END IF;
	IF bool_small_geo THEN
		IF bool_estimate THEN sql := sql || sql_small_geo || E'\n\n'; END IF;
		IF bool_moe THEN sql := sql || sql_small_geo_moe || E'\n\n'; END IF;
	END IF;

	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$sql_import_sequences$ LANGUAGE plpgsql;
