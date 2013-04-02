/*
--RUN ONCE ONLY!!! 
CREATE SCHEMA acs2010_5yr;
*/

SET search_path = acs2010_5yr, public;
SET client_encoding = 'LATIN1';

DROP FUNCTION IF EXISTS get_refyear_period();
CREATE FUNCTION get_refyear_period() RETURNS text AS $get_refyear_period$
BEGIN
	RETURN '20105';
END;
$get_refyear_period$ LANGUAGE plpgsql;

--CREATE TABLE TO HOLD FIELD DEFINITIONS FOR geoheader
CREATE TABLE geoheader_schema (
	line_number serial,
	Name varchar,
	Descr varchar,
	Field_Size int,
	Starting_Position int,
	sumlevels varchar,
	PRIMARY KEY (name)
);

--INSERT FIELD DEFINITIONS INTO geoheader_schema
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('fileid', 'Always equal to ACS Summary File identification', 6, 1, 'All Summary Levels');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('stusab', 'State Postal Abbreviation', 2, 7, 'All Summary Levels');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('sumlevel', 'Summary Level', 3, 9, 'All Summary Levels');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('component', 'Geographic Component', 2, 12, 'All Summary Levels');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('logrecno', 'Logical Record Number', 7, 14, 'All Summary Levels');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('us', 'US', 1, 21, '10');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('region', 'Census Region', 1, 22, '20');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('division', 'Census Division', 1, 23, '30');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('statece', 'State (Census Code)', 2, 24, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('state', 'State (FIPS Code)', 2, 26, '040, 050, 060, 160, 230, 312, 352,500, 795, 950, 960, 970');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('county', 'County of current residence', 3, 28, '050, 060');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('cousub', 'County Subdivision (FIPS)', 5, 31, '60');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('place', 'Place (FIPS Code)', 5, 36, '160, 312, 352');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('tract', 'Census Tract', 6, 41, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blkgrp', 'Block Group', 1, 47, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('concit', 'Consolidated City', 5, 48, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('aianhh', 'American Indian Area/Alaska Native Area/ Hawaiian Home Land (Census)', 4, 53, '250');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('aianhhfp', 'American Indian Area/Alaska Native Area/ Hawaiian Home Land (FIPS)', 5, 57, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('aihhtli', 'American Indian Trust Land/ Hawaiian Home Land Indicator', 1, 62, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('aitsce', 'American Indian Tribal Subdivision (Census)', 3, 63, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('aits', 'American Indian Tribal Subdivision (FIPS)', 5, 66, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('anrc', 'Alaska Native Regional Corporation (FIPS)', 5, 71, '230');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('cbsa', 'Metropolitan and Micropolitan Statistical Area', 5, 76, '310, 312, 314');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('csa', 'Combined Statistical Area', 3, 81, '330');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('metdiv', 'Metropolitan Statistical Area-Metropolitan Division', 5, 84, '314');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('macc', 'Metropolitan Area Central City', 1, 89, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('memi', 'Metropolitan/Micropolitan Indicator Flag', 1, 90, '010, 020, 030, 040, 314');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('necta', 'New England City and Town Area', 5, 91, '335, 350, 352');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('cnecta', 'New England City and Town Combined Statistical Area', 3, 96, '335');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('nectadiv', 'New England City and Town Area Division', 5, 99, '355');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('ua', 'Urban Area', 5, 104, '400');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank1', NULL, 5, 109, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('cdcurr', 'Current Congressional District ***', 2, 114, '500');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('sldu', 'State Legislative District Upper', 3, 116, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('sldl', 'State Legislative District Lower', 3, 119, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank2', NULL, 6, 122, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank3', NULL, 3, 128, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank4', NULL, 5, 131, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('submcd', 'Subminor Civil Division (FIPS)', 5, 136, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('sdelm', 'State-School District (Elementary)', 5, 141, '950');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('sdsec', 'State-School District (Secondary)', 5, 146, '960');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('sduni', 'State-School District (Unified)', 5, 151, '970');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('ur', 'Urban/Rural', 1, 156, '010, 020, 030, 040');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('pci', 'Principal City Indicator', 1, 157, '010, 020, 030, 040, 312, 352');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank5', NULL, 6, 158, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank6', NULL, 5, 164, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('puma5', 'Public Use Microdata Area - 5% File', 5, 169, '795');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank7', NULL, 5, 174, 'Reserved for future use');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('geoid', 'Geographic Identifier', 40, 179, 'All Summary Levels');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('name', 'Area Name', 200, 219, 'All Summary Levels');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('bttr', 'Tribal Tract', 6, 419, '256, 258, 291, 292, 293, 294');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('btbg', 'Tribal Block Group', 1, 425, '258, 293, 294');
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank8', NULL, 50, 426, 'Reserved for future use');

/*IMPORT DATA DICTIONARY. DICTIONARY FILE CAN BE DOWNLOADED FROM 
http://www2.census.gov/acs2010_5yr/summaryfile/ AS TEXT OR EXCEL
FILE. CHANGE NAME OF UPLOAD FOLDER.*/
CREATE TABLE data_dictionary (
	File_ID varchar, Table_ID varchar, Sequence_Number int, Line_Number double precision, 
	Start_Position int, Total_Cells_in_Table varchar, Total_Cells_in_Sequence int, 
	Table_Title varchar, Subject_Area varchar
);

--Will fail if table structure doesn't match imported file
SELECT sql_import_data_dictionary();

--DETERMINE SEQUENCES FROM DATA DICTIONARY. NOTE US/PR-ONLY SEQUENCES.
CREATE VIEW vw_sequence AS
SELECT 
	sequence_number AS seq, 'seq' || lpad(sequence_number::varchar, 4, '0') AS seq_id, 
	subject_area, total_cells_in_sequence AS seq_cells, 
	CASE WHEN sequence_number IN (1, 2, 17, 18, 20, 21, 22, 23, 24, 107) THEN 'us'
		WHEN sequence_number IN (109, 110, 111, 112, 113, 114, 115, 116, 117, 118) THEN 'pr'
		ELSE NULL
	END AS coverage
FROM data_dictionary
WHERE total_cells_in_sequence IS NOT NULL
;

--DETERMINE SUBJECT TABLES FROM DATA DICTIONARY
CREATE VIEW vw_subject_table AS
SELECT
	Subject_Area, Table_ID, initcap(Table_Title) AS table_title, universe, 
	Sequence_Number AS seq, 'seq' || lpad(sequence_number::varchar, 4, '0') AS seq_id,
	Start_Position, split_part(Total_Cells_in_Table, ' ', 1)::int AS table_cells
FROM data_dictionary d JOIN (
	SELECT table_id, sequence_number, table_title AS universe
	FROM data_dictionary
	WHERE table_title LIKE 'Universe%'
	) u USING (table_id, sequence_number)
WHERE Total_Cells_in_Table != ''
;

--DETERMINE DATA CELLS FROM DATA DICTIONARY
CREATE VIEW vw_cell AS
SELECT 
	table_id, table_id || lpad(line_number::varchar, 3, '0') AS cell_id,
	seq, seq_id, line_number AS table_position,
	start_position + line_number - min(line_number) OVER (PARTITION BY seq) - 6 AS seq_position,
	descr
FROM 
	(SELECT table_id, sequence_number AS seq, line_number, table_title AS descr FROM data_dictionary 
		WHERE line_number = round(line_number)) d
	JOIN vw_subject_table USING (table_id, seq)
;
