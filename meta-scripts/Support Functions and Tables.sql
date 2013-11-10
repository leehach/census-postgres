SET search_path = public;

DROP FUNCTION IF EXISTS set_census_upload_root(text);
CREATE FUNCTION set_census_upload_root(upload_root text) RETURNS void AS $set_census_upload_root$
DECLARE
	getter TEXT;
BEGIN
	DROP FUNCTION IF EXISTS get_census_upload_root();
	getter := E'CREATE FUNCTION get_census_upload_root() RETURNS text AS $get_census_upload_root$
	BEGIN
		RETURN \'' || upload_root || E'\';
	END;
	$get_census_upload_root$ LANGUAGE plpgsql;';
	EXECUTE getter;
END;
$set_census_upload_root$ LANGUAGE plpgsql;

--SELECT set_census_upload_root('/your/upload/path');

DROP FUNCTION IF EXISTS join_sequences(text[]);
CREATE FUNCTION join_sequences(seq_id text[]) RETURNS text AS $function$
DECLARE 
	i INT;
	join_clause TEXT := '';
BEGIN	
	join_clause := seq_id[1];
	FOR i IN 2 .. array_upper(seq_id, 1) LOOP
		join_clause := join_clause || ' JOIN ' || seq_id[i] || ' USING (stusab, logrecno)';
	END LOOP;
	RETURN join_clause;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_import_data_dictionary(text);
CREATE FUNCTION sql_import_data_dictionary(filename text = 'Sequence_Number_and_Table_Number_Lookup.txt') RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN	

	sql := E'COPY data_dictionary FROM \'' || get_census_upload_root() || '/' || current_schema || '/' || filename || E'\' WITH CSV HEADER NULL \'\';';
	EXECUTE sql;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_create_import_log();
CREATE FUNCTION sql_create_import_log() RETURNS text AS $function$
DECLARE 
	sql TEXT := '';
BEGIN	

	sql := 'CREATE TABLE import_log (
		seq int, stusab varchar(2), geo varchar, estimate_moe text);';
	EXECUTE sql;
	RETURN sql;
END;
$function$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS sql_populate_import_log();
CREATE FUNCTION sql_populate_import_log() RETURNS void AS $function$
DECLARE 
	v record;
	i int := 0;
BEGIN	
	TRUNCATE import_log;
	
	INSERT INTO import_log (seq, stusab, geo)
	SELECT DISTINCT 0, stusab, CASE sumlevel WHEN 40 THEN 'large' WHEN 140 THEN 'small' END
	FROM geoheader
	WHERE sumlevel in (40, 140);

	FOR v IN SELECT seq, seq_id FROM vw_sequence LOOP
		EXECUTE $$INSERT INTO import_log (seq, stusab, geo, estimate_moe)
			SELECT DISTINCT $$ || v.seq || $$, stusab, 
				CASE sumlevel WHEN 40 THEN 'large' WHEN 140 THEN 'small' END,
				'estimate'
			FROM $$ || v.seq_id || $$ JOIN geoheader USING (stusab, logrecno)
			WHERE sumlevel in (40, 140);$$;
		EXECUTE $$INSERT INTO import_log (seq, stusab, geo, estimate_moe)
			SELECT DISTINCT $$ || v.seq || $$, stusab, 
				CASE sumlevel WHEN 40 THEN 'large' WHEN 140 THEN 'small' END,
				'moe'
			FROM $$ || v.seq_id || $$_moe JOIN geoheader USING (stusab, logrecno)
			WHERE sumlevel in (40, 140);$$;			
	END LOOP;
	
	RETURN;
END;
$function$ LANGUAGE plpgsql;

--CREATE LIST OF STATES/GEOGRAPHIC ENTITIES FOR PURPOSES OF ITERATING FILES FOR IMPORT
DROP TABLE IF EXISTS stusab;
CREATE TABLE stusab (
	stusab varchar(2),
	PRIMARY KEY (stusab)
);
INSERT INTO stusab VALUES ('ak');
INSERT INTO stusab VALUES ('al');
INSERT INTO stusab VALUES ('ar');
INSERT INTO stusab VALUES ('az');
INSERT INTO stusab VALUES ('ca');
INSERT INTO stusab VALUES ('co');
INSERT INTO stusab VALUES ('ct');
INSERT INTO stusab VALUES ('dc');
INSERT INTO stusab VALUES ('de');
INSERT INTO stusab VALUES ('fl');
INSERT INTO stusab VALUES ('ga');
INSERT INTO stusab VALUES ('hi');
INSERT INTO stusab VALUES ('ia');
INSERT INTO stusab VALUES ('id');
INSERT INTO stusab VALUES ('il');
INSERT INTO stusab VALUES ('in');
INSERT INTO stusab VALUES ('ks');
INSERT INTO stusab VALUES ('ky');
INSERT INTO stusab VALUES ('la');
INSERT INTO stusab VALUES ('ma');
INSERT INTO stusab VALUES ('md');
INSERT INTO stusab VALUES ('me');
INSERT INTO stusab VALUES ('mi');
INSERT INTO stusab VALUES ('mn');
INSERT INTO stusab VALUES ('mo');
INSERT INTO stusab VALUES ('ms');
INSERT INTO stusab VALUES ('mt');
INSERT INTO stusab VALUES ('nc');
INSERT INTO stusab VALUES ('nd');
INSERT INTO stusab VALUES ('ne');
INSERT INTO stusab VALUES ('nh');
INSERT INTO stusab VALUES ('nj');
INSERT INTO stusab VALUES ('nm');
INSERT INTO stusab VALUES ('nv');
INSERT INTO stusab VALUES ('ny');
INSERT INTO stusab VALUES ('oh');
INSERT INTO stusab VALUES ('ok');
INSERT INTO stusab VALUES ('or');
INSERT INTO stusab VALUES ('pa');
INSERT INTO stusab VALUES ('pr');
INSERT INTO stusab VALUES ('ri');
INSERT INTO stusab VALUES ('sc');
INSERT INTO stusab VALUES ('sd');
INSERT INTO stusab VALUES ('tn');
INSERT INTO stusab VALUES ('tx');
INSERT INTO stusab VALUES ('us');
INSERT INTO stusab VALUES ('ut');
INSERT INTO stusab VALUES ('va');
INSERT INTO stusab VALUES ('vt');
INSERT INTO stusab VALUES ('wa');
INSERT INTO stusab VALUES ('wi');
INSERT INTO stusab VALUES ('wv');
INSERT INTO stusab VALUES ('wy');

/**NOT USED, TEMPORARILY RETAINED

--set_refyear_period() creates getter function in EACH census schema.
--Called in Data Dictionary script for EACH Census product.
--refyear_period used to construct Census product filenames (e.g. g20105ak.txt).
DROP FUNCTION IF EXISTS set_refyear_period(text);
CREATE FUNCTION set_refyear_period(refyear_period text) RETURNS void AS $set_refyear_period$
DECLARE
	getter TEXT;
BEGIN
	DROP FUNCTION IF EXISTS get_refyear_period();
	getter := E'CREATE FUNCTION get_refyear_period() RETURNS text AS $get_refyear_period$
	BEGIN
		RETURN \'' || refyear_period || E'\';
	END;
	$get_refyear_period$ LANGUAGE plpgsql;';
	EXECUTE getter;
END;
$set_refyear_period$ LANGUAGE plpgsql;
***/