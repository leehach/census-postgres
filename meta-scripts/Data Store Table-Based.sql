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
BEGIN	
	SELECT array_to_string(array_agg(sql1), E'\n'), array_to_string(array_agg(sql2), E'\n') 
	INTO sql_estimate, sql_moe
	FROM (
		SELECT 
			seq,
			CASE WHEN seq_position = min(seq_position) OVER (PARTITION BY seq) THEN 
				'CREATE TABLE ' || seq_id || E' (\n'
				|| E'\tfileid varchar(6),\n\tfiletype varchar(6), \n\tstusab varchar(2), \n'
				|| E'\tchariter varchar(3), \n\tseq varchar(4), \n\tlogrecno int,\n' 
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
				|| E'\tchariter varchar(3), \n\tseq varchar(4), \n\tlogrecno int,\n' 
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
				|| E'\tstusab, logrecno,\n' 
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
				|| E'\tstusab, logrecno,\n' 
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

	sql := sql_estimate || E'\n\n' || sql_moe;
	IF exec THEN 
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
		where 	seq = any (seq_criteria2)
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

