SET search_path = public;

--CREATE DDL FOR STORAGE BY SEQUENCE
DROP FUNCTION IF EXISTS sql_drop_storage_tables(boolean);
CREATE FUNCTION sql_drop_storage_tables(exec boolean = FALSE) RETURNS text AS $function$
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
			'DROP TABLE IF EXISTS ' || seq_id || E' CASCADE;' AS sql1,
			'DROP TABLE IF EXISTS ' || seq_id || E'_moe CASCADE;' AS sql2
		FROM vw_sequence
		ORDER BY seq
		) s
	;

	sql := sql_estimate || E'\n\n' || sql_moe;
	IF exec THEN 
		DELETE FROM import_log WHERE seq > 0;
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_store_by_tables(boolean);
CREATE FUNCTION sql_store_by_tables(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
	sql_estimate text;
	sql_moe text;
	geoid_def text := '';
BEGIN	
	SELECT 'geoid varchar(' || field_size || ') UNIQUE' INTO geoid_def FROM geoheader_schema where name = 'geoid';
	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT 
			seq,
			CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN 
				'CREATE TABLE ' || seq_id || E' (\n'
				|| E'\tfileid varchar(6),\n\tfiletype varchar(6), \n\tstusab varchar(2), \n'
				|| E'\tchariter varchar(3), \n\tseq varchar(4), \n\tlogrecno int,\n\t' || geoid_def || E',\n'
				ELSE ''
			END || 
			E'\t' || cell_id || ' double precision,' ||
			CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq)
				THEN E'\n\tPRIMARY KEY (stusab, logrecno)\n)\nWITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);\n'
				ELSE ''
			END AS sql1,
			CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN 
				'CREATE TABLE ' || seq_id || E'_moe (\n'
				|| E'\tfileid varchar(6),\n\tfiletype varchar(6), \n\tstusab varchar(2), \n'
				|| E'\tchariter varchar(3), \n\tseq varchar(4), \n\tlogrecno int,\n\t' || geoid_def || E',\n'
				ELSE ''
			END || 
			E'\t' || cell_id || '_moe double precision,' ||
			CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq)
				THEN E'\n\tPRIMARY KEY (stusab, logrecno)\n)\nWITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);\n'
				ELSE ''
			END AS sql2
		FROM vw_cell
		ORDER BY seq, seq_position
		) s
	;

	sql := sql_estimate || E'\n\n' || sql_moe;
	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_drop_views_stored_by_tables(boolean);
CREATE FUNCTION sql_drop_views_stored_by_tables(exec boolean = FALSE) RETURNS text AS $function$
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
			'DROP VIEW IF EXISTS ' || table_id || E';' AS sql1,
			'DROP VIEW IF EXISTS ' || table_id || E'_moe;' AS sql2
		FROM vw_subject_table
		ORDER BY seq, start_position
		) s
	;

	sql := sql_estimate || E'\n\n' || sql_moe;
	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_view_estimate_stored_by_tables(boolean);
CREATE FUNCTION sql_view_estimate_stored_by_tables(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN	
	SELECT array_to_string(array_agg(sql_statement), E'\n') INTO sql 
	FROM (
		SELECT 
			seq,
			CASE WHEN table_position = 1 THEN 'CREATE VIEW ' || table_id || E' AS SELECT \n'
				|| E'\t' || seq_id || '.stusab, ' || seq_id || '.logrecno, ' || seq_id || E'.geoid,\n' 
				ELSE ''
			END || 
			E'\t' || cell_id || 
			CASE WHEN table_position = max(table_position) OVER (PARTITION BY table_id)
				THEN E'\nFROM ' || join_clause || E';\n'
				ELSE ','
			END AS sql_statement
		FROM vw_cell JOIN (SELECT seq, coverage FROM vw_sequence) s USING (seq)
			JOIN (
				SELECT table_id, join_sequences(array_agg(seq_id)) AS join_clause
				FROM vw_subject_table JOIN (SELECT seq, coverage FROM vw_sequence) s USING (seq)
				WHERE COALESCE(coverage, 'all') != 'pr'
				GROUP BY table_id
				) j USING (table_id)
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

/*Margin of error will rarely be used without estimate, so even though
they are stored in independent sequences, subject table views return estimates
as well as margins of error
*/
DROP FUNCTION IF EXISTS sql_view_moe_stored_by_tables(boolean);
CREATE FUNCTION sql_view_moe_stored_by_tables(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN	
	SELECT array_to_string(array_agg(sql_statement), E'\n') INTO sql 
	FROM (
		SELECT 
			seq,
			CASE WHEN table_position = 1 THEN 'CREATE VIEW ' || table_id || E'_moe AS SELECT \n'
				|| E'\t' || seq_id || '.stusab, ' || seq_id || '.logrecno, ' || seq_id || E'.geoid,\n' 
				ELSE ''
			END || 
			E'\t' || cell_id || ', ' || cell_id || '_moe' ||
			CASE WHEN table_position = max(table_position) OVER (PARTITION BY table_id)
				THEN E'\nFROM ' || join_clause || E';\n'
				ELSE ','
			END AS sql_statement
		FROM vw_cell JOIN (SELECT seq, coverage FROM vw_sequence) s USING (seq)
			JOIN (
				SELECT table_id, join_sequences(array_cat(array_agg(seq_id), array_agg(seq_id || '_moe'))) AS join_clause
				FROM vw_subject_table JOIN (SELECT seq, coverage FROM vw_sequence) s USING (seq)
				WHERE COALESCE(coverage, 'all') != 'pr'
				GROUP BY table_id
				) j USING (table_id)
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

DROP FUNCTION IF EXISTS sql_insert_into_tables(boolean, int[], text);
CREATE FUNCTION sql_insert_into_tables(exec boolean = FALSE, seq_criteria int[] = ARRAY[-1], actions text = 'em') RETURNS text AS $function$
--Possibly modify to add with_geoid parameter which reads value from joined geoheader table
DECLARE 
	sql TEXT := '';
	sql_estimate TEXT;
	sql_moe TEXT;
	seq_criteria2 int[];
BEGIN	
	IF seq_criteria = ARRAY[-1] THEN 
		seq_criteria2 := (SELECT array_agg(seq) FROM vw_sequence); 
	ELSE
		seq_criteria2 := seq_criteria;
	END IF;

	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT 	
			seq, 
			array_to_string(array_agg(insert_list_estimate), E'\n') || E'\n' || array_to_string(array_agg(values_list_estimate), E'\n') AS sql1, 
			array_to_string(array_agg(insert_list_moe), E'\n') || E'\n' || array_to_string(array_agg(values_list_moe), E'\n') AS sql2
		FROM (
			SELECT
				seq,
				CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN
					'INSERT INTO ' || seq_id || ' (' ||
					E'\n\tfileid, filetype, stusab, chariter, seq, logrecno,\n' 
					ELSE ''
				END || 
				E'\t' || cell_id ||
				CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq) THEN
					E'\n)'
					ELSE ','
				END AS insert_list_estimate,

				CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN
					E'SELECT fileid, filetype, upper(stusab), chariter, seq, logrecno::int,\n' 
					ELSE ''
				END || 
				E'\tNULLIF(NULLIF(' || cell_id || E', \'\'), \'.\')::double precision' ||
				CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq) THEN
					E'\nFROM tmp_' || seq_id || ';'
					ELSE ','
				END AS values_list_estimate,

				CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN
					'INSERT INTO ' || seq_id || '_moe (' ||
					E'\n\tfileid, filetype, stusab, chariter, seq, logrecno,\n' 
					ELSE ''
				END || 
				E'\t' || cell_id || '_moe' ||
				CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq) THEN
					E'\n)'
					ELSE ','
				END AS insert_list_moe,

				CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN
					E'SELECT fileid, filetype, upper(stusab), chariter, seq, logrecno::int,\n' 
					ELSE ''
				END || 
				E'\tNULLIF(NULLIF(' || cell_id || E'_moe, \'\'), \'.\')::double precision' ||
				CASE WHEN seq_position = max(seq_position) OVER (PARTITION BY seq) THEN
					E'\nFROM tmp_' || seq_id || '_moe;'
					ELSE ','
				END AS values_list_moe
			FROM
				vw_cell
			WHERE	seq = ANY (seq_criteria2)
			ORDER BY seq, seq_position
			) step1
		GROUP BY seq
		) step2
	;

	--e means Estimates
	--m means Marging of Error
	--Missing e implies m, missing m implies e
	IF actions ILIKE '%e%' OR actions NOT ILIKE '%m%' THEN
		sql := sql || sql_estimate || E'\n\n'; 
	END IF;
	IF actions ILIKE '%m%' OR actions NOT ILIKE '%e%' THEN
		sql := sql || sql_moe || E'\n\n'; 
	END IF;
	
	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

--Complete import with subsequent drop of staging tables
DROP FUNCTION IF EXISTS sql_import_sequences_and_insert_into_tables(boolean, text[], int[], text);  
CREATE FUNCTION sql_import_sequences_and_insert_into_tables(exec boolean = FALSE, stusab_criteria text[] = ARRAY['%'], 
	seq_criteria int[] = ARRAY[-1], actions text = 'atem'
	) RETURNS int AS $function$
DECLARE 
	seq_criteria2 int[];
	stusab_criteria2 text[];
	geo_criteria text[];
	estimate_moe_criteria text[];
BEGIN	
	IF exec = FALSE THEN RETURN 0; END IF;

	IF seq_criteria = ARRAY[-1] THEN 
		seq_criteria2 := (SELECT array_agg(seq) FROM vw_sequence); 
	ELSE
		seq_criteria2 := seq_criteria;
	END IF;

	SELECT sql_drop_import_tables(exec, seq_criteria2, actions);
	SELECT sql_create_import_tables(exec, seq_criteria2, actions);
	SELECT sql_import_sequences(exec, stusab_criteria, seq_criteria2, actions);
	SELECT sql_insert_into_tables(exec, seq_criteria2, actions);
	SELECT sql_drop_import_tables(exec, seq_criteria2, actions);

	IF stusab_criteria = ARRAY['%'] THEN 
		stusab_criteria2 := (SELECT array_agg(stusab) FROM stusab); 
	ELSE
		stusab_criteria2 := stusab_criteria;
	END IF;

	IF actions ILIKE '%a%' OR actions NOT ILIKE '%t%' THEN geo_criteria = geo_criteria || ARRAY['large']; END IF;
	IF actions ILIKE '%t%' OR actions NOT ILIKE '%a%' THEN geo_criteria = geo_criteria || ARRAY['small']; END IF;

	IF actions ILIKE '%e%' OR actions NOT ILIKE '%m%' THEN estimate_moe_criteria = estimate_moe_criteria || ARRAY['estimate']; END IF;
	IF actions ILIKE '%m%' OR actions NOT ILIKE '%e%' THEN estimate_moe_criteria = estimate_moe_criteria || ARRAY['moe']; END IF;
	
	INSERT INTO import_log (seq, stusab, geo, estimate_moe)
	SELECT seq, stusab, geo, estimate_moe
	FROM (SELECT unnest(seq_criteria2) AS seq) a,
		(SELECT unnest(stusab_criteria2) AS stusab) b,
		(SELECT unnest(geo_criteria) AS geo) c,
		(SELECT unnest(estimate_moe_criteria) AS estimate_moe) d
	;

	RETURN 1;
END;
$function$ LANGUAGE plpgsql;


--Maintenance Functions
DROP FUNCTION IF EXISTS sql_truncate_storage_tables(boolean, int[], text);
CREATE FUNCTION sql_truncate_storage_tables(exec boolean = FALSE, seq_criteria int[] = ARRAY[-1], actions text = 'em') RETURNS text AS $function$
DECLARE
	sql TEXT := '';
	sql_estimate text;
	sql_moe text;
	seq_criteria2 int[];
BEGIN	
	IF seq_criteria = ARRAY[-1] THEN 
		seq_criteria2 := (SELECT array_agg(seq) FROM vw_sequence); 
	ELSE
		seq_criteria2 := seq_criteria;
	END IF;

	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT
			seq,
			'TRUNCATE ' || seq_id || ';' AS sql1,
			'TRUNCATE ' || seq_id || '_moe;' AS sql2
		FROM 	vw_sequence
		where 	seq = any (seq_criteria2)
		ORDER BY seq
		) s
	;

	--e means Estimates
	--m means Marging of Error
	--Missing e implies m, missing m implies e
	IF actions ILIKE '%e%' OR actions NOT ILIKE '%m%' THEN
		sql := sql || sql_estimate || E'\n\n'; 
	END IF;
	IF actions ILIKE '%m%' OR actions NOT ILIKE '%e%' THEN
		sql := sql || sql_moe || E'\n\n'; 
	END IF;

	IF exec THEN 
		DELETE FROM import_log WHERE seq > 0;
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_autovacuum_storage_tables(boolean, boolean, int[], text);
CREATE FUNCTION sql_autovacuum_storage_tables(set_autovacuum boolean, exec boolean = FALSE, seq_criteria int[] = ARRAY[-1], actions text = 'em') RETURNS text AS $function$
DECLARE
	sql TEXT := '';
	sql_estimate text;
	sql_moe text;
	seq_criteria2 int[];
BEGIN	
	IF seq_criteria = ARRAY[-1] THEN 
		seq_criteria2 := (SELECT array_agg(seq) FROM vw_sequence); 
	ELSE
		seq_criteria2 := seq_criteria;
	END IF;

	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT
			seq,
			'ALTER TABLE ' || seq_id || ' SET (autovacuum_enabled = ' || set_autovacuum || ', toast.autovacuum_enabled = ' || set_autovacuum || ');' AS sql1,
			'ALTER TABLE ' || seq_id || '_moe SET (autovacuum_enabled = ' || set_autovacuum || ', toast.autovacuum_enabled = ' || set_autovacuum || ');' AS sql2
		FROM 	vw_sequence
		WHERE 	seq = any (seq_criteria2)
		ORDER BY seq
		) s
	;

	--e means Estimates
	--m means Marging of Error
	--Missing e implies m, missing m implies e
	IF actions ILIKE '%e%' OR actions NOT ILIKE '%m%' THEN
		sql := sql || sql_estimate || E'\n\n'; 
	END IF;
	IF actions ILIKE '%m%' OR actions NOT ILIKE '%e%' THEN
		sql := sql || sql_moe || E'\n\n'; 
	END IF;

	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_add_geoid_to_storage_tables(boolean);
CREATE FUNCTION sql_add_geoid_to_storage_tables(exec boolean = FALSE) RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
	sql_estimate text;
	sql_moe text;
	geoid_def text := '';
BEGIN	
	SELECT 'geoid varchar(' || field_size || ') UNIQUE' INTO geoid_def FROM geoheader_schema where name = 'geoid';

	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT
			seq,
			'ALTER TABLE ' || seq_id || ' ADD COLUMN ' || geoid_def || ';' AS sql1,
			'ALTER TABLE ' || seq_id || '_moe ADD COLUMN ' || geoid_def || ';' AS sql2
		FROM 	vw_sequence
		ORDER BY seq
		) s
	;

	sql := sql_estimate || E'\n\n' || sql_moe;
	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_update_geoid_storage_tables(boolean, int[], text);
CREATE FUNCTION sql_update_geoid_storage_tables(exec boolean = FALSE, seq_criteria int[] = ARRAY[-1], actions text = 'em') RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
	sql_estimate text;
	sql_moe text;
	geoid_def text := '';
	seq_criteria2 int[];
BEGIN	
	IF seq_criteria = ARRAY[-1] THEN 
		seq_criteria2 := (SELECT array_agg(seq) FROM vw_sequence); 
	ELSE
		seq_criteria2 := seq_criteria;
	END IF;
	SELECT 'geoid varchar(' || field_size || ') UNIQUE' INTO geoid_def FROM geoheader_schema where name = 'geoid';

	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT
			seq,
			'UPDATE ' || seq_id || ' s SET geoid = g.geoid FROM geoheader g WHERE s.stusab = g.stusab AND s.logrecno = g.logrecno;' AS sql1,
			'UPDATE ' || seq_id || '_moe s SET geoid = g.geoid FROM geoheader g WHERE s.stusab = g.stusab AND s.logrecno = g.logrecno;' AS sql2
		FROM 	vw_sequence
		WHERE 	seq = any (seq_criteria2)
		ORDER BY seq
		) s
	;

	--e means Estimates
	--m means Marging of Error
	--Missing e implies m, missing m implies e
	IF actions ILIKE '%e%' OR actions NOT ILIKE '%m%' THEN
		sql := sql || sql_estimate || E'\n\n'; 
	END IF;
	IF actions ILIKE '%m%' OR actions NOT ILIKE '%e%' THEN
		sql := sql || sql_moe || E'\n\n'; 
	END IF;

	IF exec THEN 
		EXECUTE sql; 
		RETURN 'Success!';
	ELSE
		RETURN sql;
	END IF;
END;
$function$ LANGUAGE plpgsql;
