SET search_path = acs2010_spt, public;
SET client_encoding = 'LATIN1';
SELECT sql_create_tmp_geoheader(FALSE);
SELECT sql_import_geoheader(FALSE); --Imports all states
SELECT sql_create_import_tables(FALSE);
SELECT sql_import_sequences(FALSE, ARRAY['ny', 'nj'], ARRAY[1], 'e'); --Imports margins of error and estimates for all states and sequences
SELECT sql_create_geoheader(FALSE);
SELECT sql_geoheader_comments(FALSE);

--For table-based data store:

SELECT sql_store_by_tables(FALSE);
SELECT sql_view_estimate_stored_by_tables(FALSE);
SELECT sql_view_moe_stored_by_tables(FALSE);
SELECT sql_parse_tmp_geoheader(FALSE); --Copies all data from tmp_geoheader to geoheader
SELECT sql_insert_into_tables(FALSE); --Copies all estimates and margins of error to sequence tables
