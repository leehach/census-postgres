/*
--RUN ONCE ONLY!!! 
CREATE SCHEMA acs2010_spt;
*/

SET search_path = acs2010_spt, public;
SET client_encoding = 'LATIN1';

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
INSERT INTO geoheader_schema (name, descr, field_size, starting_position, sumlevels) VALUES ('blank8', NULL, 43, 426, 'Reserved for future use');

/*IMPORT DATA DICTIONARY. DICTIONARY FILE CAN BE DOWNLOADED FROM 
http://www2.census.gov/acs2010_SPT_AIAN/SelectedPopulationTables/ AS TEXT OR EXCEL
FILE. CHANGE NAME OF UPLOAD FOLDER.
NOTE: DOWNLOADED FILE WILL NOT WORK DUE TO QUOTED NUMERIC FIELDS, AND USE OF BOTH 
SPACES AND PERIODS TO INDICATE MISSING DATA. COPY IN census-postgres GITHUB HAS
HAD PROBLEMATIC CHARACTERS STRIPPED.*/
CREATE TABLE data_dictionary (
	File_ID varchar, Table_ID varchar, Sequence_Number int, Line_Number double precision, 
	Start_Position int, Total_Cells_in_Table varchar, Total_Cells_in_Sequence int, 
	Table_Title varchar, Subject_Area varchar
);

--Will fail if table structure doesn't match imported file
SELECT sql_import_data_dictionary(); 

--DETERMINE SEQUENCES FROM DATA DICTIONARY. NOTE US/PR-ONLY SEQUENCES.
--TAKEN FROM http://www2.census.gov/acs2010_SPT_AIAN/SelectedPopulationTables/ACS_SPT_SF_Tech_Doc.pdf APPENDIX C.5.
CREATE VIEW vw_sequence AS
SELECT 
	sequence_number AS seq, 'seq' || lpad(sequence_number::varchar, 4, '0') AS seq_id, 
	subject_area, total_cells_in_sequence AS seq_cells, 
	CASE WHEN sequence_number IN (2, 4, 5, 32) THEN 'us'
		WHEN sequence_number IN (34, 35, 36, 37) THEN 'pr'
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
WHERE Total_Cells_in_Table IS NOT NULL
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

--ADD AND POPULATE CHARITER SUPPORT TABLE
DROP TABLE IF EXISTS chariter;
CREATE TABLE chariter (
	chariter varchar(3),
	group_name varchar,
	PRIMARY KEY (chariter)
);

INSERT INTO chariter (chariter, group_name) VALUES ('001', 'Total population');
--Race Groups
INSERT INTO chariter (chariter, group_name) VALUES ('002', 'White alone (100-199)');
INSERT INTO chariter (chariter, group_name) VALUES ('003', 'White alone or in combination with one or more other races (100-199) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('004', 'Black or African American alone (200-299)');
INSERT INTO chariter (chariter, group_name) VALUES ('005', 'Black or African American alone or in combination with one or more other races (200-299) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('006', 'American Indian and Alaska Native alone (300, A01-Z99)');
INSERT INTO chariter (chariter, group_name) VALUES ('007', 'American Indian alone (A01-M43)');
INSERT INTO chariter (chariter, group_name) VALUES ('008', 'Alaska Native alone (M44-R99)');
INSERT INTO chariter (chariter, group_name) VALUES ('009', 'American Indian and Alaska Native alone or in combination with one or more other races (300, A01-Z99) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('010', 'American Indian alone or in any combination (A01-M43) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('011', 'Alaska Native alone or in any combination (M44-R99) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('012', 'Asian alone (400-499)');
INSERT INTO chariter (chariter, group_name) VALUES ('013', 'Asian Indian alone (400-401)');
INSERT INTO chariter (chariter, group_name) VALUES ('014', 'Bangladeshi alone (402)');
INSERT INTO chariter (chariter, group_name) VALUES ('072', 'Bhutanese alone (403)');
INSERT INTO chariter (chariter, group_name) VALUES ('073', 'Burmese alone (404)');
INSERT INTO chariter (chariter, group_name) VALUES ('015', 'Cambodian alone (405-409)');
INSERT INTO chariter (chariter, group_name) VALUES ('016', 'Chinese alone (410-419)');
INSERT INTO chariter (chariter, group_name) VALUES ('017', 'Chinese (except Taiwanese) alone (410-411)');
INSERT INTO chariter (chariter, group_name) VALUES ('018', 'Taiwanese alone (412-419)');
INSERT INTO chariter (chariter, group_name) VALUES ('019', 'Filipino alone (420-421)');
INSERT INTO chariter (chariter, group_name) VALUES ('020', 'Hmong alone (422)');
INSERT INTO chariter (chariter, group_name) VALUES ('021', 'Indonesian alone (423-429)');
INSERT INTO chariter (chariter, group_name) VALUES ('022', 'Japanese alone (430-439)');
INSERT INTO chariter (chariter, group_name) VALUES ('023', 'Korean alone (440-441)');
INSERT INTO chariter (chariter, group_name) VALUES ('024', 'Laotian alone (442)');
INSERT INTO chariter (chariter, group_name) VALUES ('025', 'Malaysian alone (443)');
INSERT INTO chariter (chariter, group_name) VALUES ('075', 'Mongolian alone (465)');
INSERT INTO chariter (chariter, group_name) VALUES ('076', 'Nepalese alone (472)');
INSERT INTO chariter (chariter, group_name) VALUES ('026', 'Pakistani alone (445)');
INSERT INTO chariter (chariter, group_name) VALUES ('027', 'Sri Lankan alone (446)');
INSERT INTO chariter (chariter, group_name) VALUES ('028', 'Thai alone (447-449)');
INSERT INTO chariter (chariter, group_name) VALUES ('029', 'Vietnamese alone (450-459)');
INSERT INTO chariter (chariter, group_name) VALUES ('031', 'Asian alone or in combination with one or more other races (400-499) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('032', 'Asian Indian alone or in any combination (400-401) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('033', 'Bangladeshi alone or in any combination (402) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('080', 'Bhutanese alone or in any combination (403) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('081', 'Burmese alone or in any combination (404) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('034', 'Cambodian alone or in any combination (405-409) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('035', 'Chinese alone or in any combination (410-419) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('036', 'Chinese (except Taiwanese) alone or in any combination (410-411) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('037', 'Taiwanese alone or in any combination (412-419) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('038', 'Filipino alone or in any combination (420-421) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('039', 'Hmong alone or in any combination (422) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('040', 'Indonesian alone or in any combination (423-429) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('041', 'Japanese alone or in any combination (430-439) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('042', 'Korean alone or in any combination (440-441) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('043', 'Laotian alone or in any combination (442) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('044', 'Malaysian alone or in any combination (443) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('083', 'Mongolian alone or in any combination (465) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('084', 'Nepalese alone or in any combination (472) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('085', 'Okinawan alone or in any combination (444) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('045', 'Pakistani alone or in any combination (445) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('046', 'Sri Lankan alone or in any combination (446) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('047', 'Thai alone or in any combination (447-449) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('048', 'Vietnamese alone or in any combination (450-459) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('050', 'Native Hawaiian and Other Pacific Islander alone (500-599)');
INSERT INTO chariter (chariter, group_name) VALUES ('051', 'Polynesian alone (500-519)');
INSERT INTO chariter (chariter, group_name) VALUES ('052', 'Native Hawaiian alone (500-503)');
INSERT INTO chariter (chariter, group_name) VALUES ('053', 'Samoan alone (510-511)');
INSERT INTO chariter (chariter, group_name) VALUES ('054', 'Tongan alone (513)');
INSERT INTO chariter (chariter, group_name) VALUES ('055', 'Micronesian alone (520-529, 531-541)');
INSERT INTO chariter (chariter, group_name) VALUES ('056', 'Guamanian or Chamorro alone (520-522)');
INSERT INTO chariter (chariter, group_name) VALUES ('096', 'Marshallese alone (532)');
INSERT INTO chariter (chariter, group_name) VALUES ('057', 'Melanesian alone (542-546)');
INSERT INTO chariter (chariter, group_name) VALUES ('058', 'Fijian alone (542)');
INSERT INTO chariter (chariter, group_name) VALUES ('060', 'Native Hawaiian and Other Pacific Islander alone or in combination with one or more other races (500-599) & (100-299) or (300, A01-Z99) or(400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('061', 'Polynesian alone or in any combination (500-519) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('062', 'Native Hawaiian alone or in any combination (500-503) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('063', 'Samoan alone or in any combination (510-511) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('064', 'Tongan alone or in any combination (513) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('065', 'Micronesian alone or in any combination (520-529, 531-541) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('066', 'Guamanian or Chamorro alone or in any combination (520-522) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('176', 'Marshallese alone or in any combination (532) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('177', 'Palauan alone or in any combination (533) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('067', 'Melanesian alone or in any combination (542-546) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('068', 'Fijian alone or in any combination (542) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('070', 'Some Other Race alone (600-699)');
INSERT INTO chariter (chariter, group_name) VALUES ('071', 'Some Other Race alone or in combination with one or more other races (600-699) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('100', 'Two or more races');
INSERT INTO chariter (chariter, group_name) VALUES ('101', 'Two races with Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('103', 'Two races without Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('105', 'White; Black or African American');
INSERT INTO chariter (chariter, group_name) VALUES ('106', 'White; American Indian and Alaska Native');
INSERT INTO chariter (chariter, group_name) VALUES ('107', 'White; Asian');
INSERT INTO chariter (chariter, group_name) VALUES ('108', 'White; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('109', 'White; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('110', 'Black or African American; American Indian and Alaska Native');
INSERT INTO chariter (chariter, group_name) VALUES ('111', 'Black or African American; Asian');
INSERT INTO chariter (chariter, group_name) VALUES ('112', 'Black or African American; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('113', 'Black or African American; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('114', 'American Indian and Alaska Native; Asian');
INSERT INTO chariter (chariter, group_name) VALUES ('115', 'American Indian and Alaska Native; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('116', 'American Indian and Alaska Native; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('117', 'Asian; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('118', 'Asian; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('119', 'Native Hawaiian and Other Pacific Islander; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('120', 'White; Black or African American; American Indian and Alaska Native');
INSERT INTO chariter (chariter, group_name) VALUES ('121', 'White; Black or African American; Asian');
INSERT INTO chariter (chariter, group_name) VALUES ('122', 'White; Black or African American; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('123', 'White; Black or African American; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('124', 'White; American Indian and Alaska Native; Asian');
INSERT INTO chariter (chariter, group_name) VALUES ('125', 'White; American Indian and Alaska Native; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('126', 'White; American Indian and Alaska Native; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('127', 'White; Asian; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('128', 'White; Asian; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('129', 'White; Native Hawaiian and Other Pacific Islander; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('130', 'Black or African American; American Indian and Alaska Native; Asian');
INSERT INTO chariter (chariter, group_name) VALUES ('131', 'Black or African American; American Indian and Alaska Native; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('132', 'Black or African American; American Indian and Alaska Native; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('133', 'Black or African American; Asian; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('134', 'Black or African American; Asian; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('135', 'Black or African American; Native Hawaiian and Other Pacific Islander; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('136', 'American Indian and Alaska Native; Asian; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('137', 'American Indian and Alaska Native; Asian; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('139', 'Asian; Native Hawaiian and Other Pacific Islander; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('140', 'White; Black or African American; American Indian and Alaska Native; Asian');
INSERT INTO chariter (chariter, group_name) VALUES ('141', 'White; Black or African American; American Indian and Alaska Native; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('142', 'White; Black or African American; American Indian and Alaska Native; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('143', 'White; Black or African American; Asian; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('144', 'White; Black or African American; Asian; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('146', 'White; American Indian and Alaska Native; Asian; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('147', 'White; American Indian and Alaska Native; Asian; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('149', 'White; Asian; Native Hawaiian and Other Pacific Islander; Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('155', 'White; Black or African American; American Indian and Alaska Native; Asian; Native Hawaiian and Other Pacific Islander');
INSERT INTO chariter (chariter, group_name) VALUES ('586', 'White in combination with one or more other races');
INSERT INTO chariter (chariter, group_name) VALUES ('587', 'Black or African American in combination with one or more other races');
INSERT INTO chariter (chariter, group_name) VALUES ('588', 'American Indian and Alaska Native in combination with one or more other races');
INSERT INTO chariter (chariter, group_name) VALUES ('589', 'Asian in combination with one or more other races');
INSERT INTO chariter (chariter, group_name) VALUES ('590', 'Native Hawaiian and Other Pacific Islander in combination with one or more other races');
INSERT INTO chariter (chariter, group_name) VALUES ('591', 'Some Other Race in combination with one or more other races');
INSERT INTO chariter (chariter, group_name) VALUES ('598', 'Three or more races with Some Other Race');
INSERT INTO chariter (chariter, group_name) VALUES ('599', 'Three or more races without Some Other Race');
--American Indian and Alaska Native tribes
INSERT INTO chariter (chariter, group_name) VALUES ('200', 'Alaskan Athabascan tribal grouping alone (M52-N27)');
INSERT INTO chariter (chariter, group_name) VALUES ('201', 'Alaskan Athabascan tribal grouping alone or in any combination (M52-N27) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('202', 'Aleut tribal grouping alone (R11-R98)');
INSERT INTO chariter (chariter, group_name) VALUES ('203', 'Aleut tribal grouping alone or in any combination (R11-R98) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('204', 'Apache tribal grouping alone (A09-A23)');
INSERT INTO chariter (chariter, group_name) VALUES ('205', 'Apache tribal grouping alone or in any combination (A09-A23) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33S', 'Arapaho tribal grouping alone (A24-A30)');
INSERT INTO chariter (chariter, group_name) VALUES ('84G', 'Arapaho tribal grouping alone or in any combination (A24-A30) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('26F', 'Assiniboine Sioux tribal grouping alone (A35, A38-A41, K22)');
INSERT INTO chariter (chariter, group_name) VALUES ('75G', 'Assiniboine Sioux tribal grouping alone or in any combination (A35, A38-A41, K22) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('206', 'Blackfeet Tribe of the Blackfeet Indian Reservation of Montana alone (A45-A50)');
INSERT INTO chariter (chariter, group_name) VALUES ('207', 'Blackfeet Tribe of the Blackfeet Indian Reservation of Montana alone or in any combination (A45-A50) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33Q', 'Canadian and French American Indian tribal grouping alone (A94)');
INSERT INTO chariter (chariter, group_name) VALUES ('84E', 'Canadian and French American Indian tribal grouping alone or in any combination (A94) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33T', 'Central American Indian tribal grouping alone (A95)');
INSERT INTO chariter (chariter, group_name) VALUES ('84H', 'Central American Indian tribal grouping alone or in any combination (A95) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('208', 'Cherokee tribal grouping alone (B21-B36)');
INSERT INTO chariter (chariter, group_name) VALUES ('209', 'Cherokee tribal grouping alone or in any combination (B21-B36) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('210', 'Cheyenne tribal grouping alone (B40-B45)');
INSERT INTO chariter (chariter, group_name) VALUES ('211', 'Cheyenne tribal grouping alone or in any combination (B40-B45) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('212', 'Chickasaw tribal grouping alone (B53-B56)');
INSERT INTO chariter (chariter, group_name) VALUES ('213', 'Chickasaw tribal grouping alone or in any combination (B53-B56) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('214', 'Chippewa tribal grouping alone (B67-B99)');
INSERT INTO chariter (chariter, group_name) VALUES ('215', 'Chippewa tribal grouping alone or in any combination (B67-B99) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('198', 'Chippewa-Cree Indians of the Rocky Boy''s Reservation tribal grouping alone or in any combination (C01-C04) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('216', 'Choctaw tribal grouping alone (C08-C16)');
INSERT INTO chariter (chariter, group_name) VALUES ('217', 'Choctaw tribal grouping alone or in any combination (C08-C16) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('199', 'Chumash tribal grouping alone or in any combination (C20-C24) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('220', 'Comanche Nation, Oklahoma tribal grouping alone (C39-C43)');
INSERT INTO chariter (chariter, group_name) VALUES ('221', 'Comanche Nation, Oklahoma tribal grouping alone or in any combination (C39-C43) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('79S', 'Confederated Salish and Kootenai Tribes of the Flathead Nation tribal grouping alone or in any combination (J35-J38) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('272', 'Confederated Tribes and Bands of the Yakama Nation tribal grouping alone (L79-L84)');
INSERT INTO chariter (chariter, group_name) VALUES ('273', 'Confederated Tribes and Bands of the Yakama Nation tribal grouping alone or in any combination (L79-L84) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('218', 'Confederated Tribes of the Colville Reservation tribal grouping alone (C35-C38)');
INSERT INTO chariter (chariter, group_name) VALUES ('219', 'Confederated Tribes of the Colville Reservation tribal grouping alone or in any combination (C35-C38) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('222', 'Cree tribal grouping alone (C59-C63)');
INSERT INTO chariter (chariter, group_name) VALUES ('223', 'Cree tribal grouping alone or in any combination (C59-C63) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('224', 'Creek tribal grouping alone (C64-C80)');
INSERT INTO chariter (chariter, group_name) VALUES ('225', 'Creek tribal grouping alone or in any combination (C64-C80) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('226', 'Crow Tribe of Montana tribal grouping alone (C83-C86)');
INSERT INTO chariter (chariter, group_name) VALUES ('227', 'Crow Tribe of Montana tribal grouping alone or in any combination (C83-C86) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('228', 'Delaware tribal grouping alone (C93-D04)');
INSERT INTO chariter (chariter, group_name) VALUES ('229', 'Delaware tribal grouping alone or in any combination (C93-D04) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('285', 'Eastern Tribes tribal grouping alone (D20-D26, D28-D41)');
INSERT INTO chariter (chariter, group_name) VALUES ('477', 'Eastern Tribes tribal grouping alone or in any combination (D20-D26, D28-D41) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('32R', 'Hopi tribal grouping alone (H39, H41)');
INSERT INTO chariter (chariter, group_name) VALUES ('84D', 'Hopi tribal grouping alone or in any combination (H39, H41) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('34A', 'Inupiat tribal grouping alone (N67-P04, P06-P29, P33-P37)');
INSERT INTO chariter (chariter, group_name) VALUES ('84M', 'Inupiat tribal grouping alone or in any combination (N67-P04, P06-P29, P33-P37) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('234', 'Iroquois tribal grouping alone (D93-E09)');
INSERT INTO chariter (chariter, group_name) VALUES ('235', 'Iroquois tribal grouping alone or in any combination (D93-E09) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('236', 'Kiowa tribal grouping alone (E30-E36)');
INSERT INTO chariter (chariter, group_name) VALUES ('237', 'Kiowa tribal grouping alone or in any combination (E30-E36) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('479', 'Luiseno tribal grouping alone or in any combination (E66-E77) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('240', 'Lumbee Indian tribal grouping alone (E78-E83)');
INSERT INTO chariter (chariter, group_name) VALUES ('241', 'Lumbee Indian tribal grouping alone or in any combination (E78-E83) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('242', 'Menominee Indian tribal grouping alone (F11-F14)');
INSERT INTO chariter (chariter, group_name) VALUES ('243', 'Menominee Indian tribal grouping alone or in any combination (F11-F14) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33V', 'Mexican American Indian tribal grouping alone (A97)');
INSERT INTO chariter (chariter, group_name) VALUES ('84K', 'Mexican American Indian tribal grouping alone or in any combination (A97) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('481', 'Miami tribal grouping alone or in any combination (F17-F23) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('482', 'Micmac tribal grouping alone or in any combination (F27-F30) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('244', 'Navajo Nation tribal grouping alone (F62-F70)');
INSERT INTO chariter (chariter, group_name) VALUES ('245', 'Navajo Nation tribal grouping alone or in any combination (F62-F70) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('483', 'Oneida Tribe of Indians of Wisconsin alone or in any combination (F99) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('246', 'Osage Tribe, Oklahoma tribal grouping alone (G04-G09)');
INSERT INTO chariter (chariter, group_name) VALUES ('247', 'Osage Tribe, Oklahoma tribal grouping alone or in any combination (G04-G09) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('248', 'Ottawa tribal grouping alone (G14-G22)');
INSERT INTO chariter (chariter, group_name) VALUES ('249', 'Ottawa tribal grouping alone or in any combination (G14-G22) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('28S', 'Paiute tribal grouping alone (G23-G49, K07)');
INSERT INTO chariter (chariter, group_name) VALUES ('84O', 'Paiute tribal grouping alone or in any combination (G23-G49, K07) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('252', 'Pima tribal grouping alone (G84-G91)');
INSERT INTO chariter (chariter, group_name) VALUES ('253', 'Pima tribal grouping alone or in any combination (G84-G91) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('84P', 'Pomo tribal grouping alone or in any combination (G99, H01-H14, H66-H69, H93-H96) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('254', 'Potawatomi tribal grouping alone (H21-H33)');
INSERT INTO chariter (chariter, group_name) VALUES ('255', 'Potawatomi tribal grouping alone or in any combination (H21-H33) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('321', 'Pueblo tribal grouping alone (H38, H40, H42-H65)');
INSERT INTO chariter (chariter, group_name) VALUES ('326', 'Pueblo tribal grouping alone or in any combination (H38, H40, H42-H65) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('258', 'Puget Sound Salish tribal grouping alone (H70-H92)');
INSERT INTO chariter (chariter, group_name) VALUES ('259', 'Puget Sound Salish tribal grouping alone or in any combination (H70-H92) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('485', 'Sac and Fox tribal grouping alone or in any combination (J19-J27) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('260', 'Seminole tribal grouping alone (J47-J57)');
INSERT INTO chariter (chariter, group_name) VALUES ('261', 'Seminole tribal grouping alone or in any combination (J47-J57) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33R', 'Shawnee tribal grouping alone (B37, J66-J73)');
INSERT INTO chariter (chariter, group_name) VALUES ('84F', 'Shawnee tribal grouping alone or in any combination (B37, J66-J73) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('262', 'Shoshone tribal grouping alone (J81-J92)');
INSERT INTO chariter (chariter, group_name) VALUES ('263', 'Shoshone tribal grouping alone or in any combination (J81-J92) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('34C', 'Sioux tribal grouping alone (K16-K21, K23-K53)');
INSERT INTO chariter (chariter, group_name) VALUES ('84Q', 'Sioux tribal grouping alone or in any combination (K16-K21, K23-K53) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33W', 'South American Indian tribal grouping alone (A98)');
INSERT INTO chariter (chariter, group_name) VALUES ('84R', 'South American Indian tribal grouping alone or in any combination (A98) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33X', 'Spanish American Indian tribal grouping alone (A99)');
INSERT INTO chariter (chariter, group_name) VALUES ('84L', 'Spanish American Indian tribal grouping alone or in any combination (A99) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('33U', 'Three Affiliated Tribes of North Dakota tribal grouping alone or in any combination (A31, D46, D67, F05) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('324', 'Tlingit-Haida tribal grouping alone (N28-N55, N59-N66)');
INSERT INTO chariter (chariter, group_name) VALUES ('329', 'Tlingit-Haida tribal grouping alone or in any combination (N28-N55, N59-N66) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('328', 'Tohono O''Odham tribal grouping alone or in any combination (K78-K86) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('323', 'Tohono O''Odham tribal grouping alone (K78-K86)');
INSERT INTO chariter (chariter, group_name) VALUES ('189', 'Tsimshian tribal grouping alone (N56-N58)');
INSERT INTO chariter (chariter, group_name) VALUES ('495', 'Tsimshian tribal grouping alone or in any combination (N56-N58) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('232', 'United Houma Nation tribal grouping alone (D78-D86)');
INSERT INTO chariter (chariter, group_name) VALUES ('233', 'United Houma Nation tribal grouping alone or in any combination (D78-D86) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('270', 'Ute tribal grouping alone (L06-L14)');
INSERT INTO chariter (chariter, group_name) VALUES ('271', 'Ute tribal grouping alone or in any combination (L06-L14) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('274', 'Yaqui tribal grouping alone (L91-L99)');
INSERT INTO chariter (chariter, group_name) VALUES ('275', 'Yaqui tribal grouping alone or in any combination (L91-L99) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('276', 'Yuman tribal grouping alone (M22-M33)');
INSERT INTO chariter (chariter, group_name) VALUES ('277', 'Yuman tribal grouping alone or in any combination (M22-M33) & (100-299) or (300, A01-Z99) or (400-999)');
INSERT INTO chariter (chariter, group_name) VALUES ('34B', 'Yup''ik tribal grouping alone (P05, P30-P32, P38-R10)');
INSERT INTO chariter (chariter, group_name) VALUES ('84N', 'Yup''ik tribal grouping alone or in any combination (P05, P30-P32, P38-R10) & (100-299) or (300, A01-Z99) or (400-999)');
--Hispanic or Latino
INSERT INTO chariter (chariter, group_name) VALUES ('400', 'Hispanic or Latino (of any race) (200-299)');
INSERT INTO chariter (chariter, group_name) VALUES ('401', 'Mexican (210-220)');
INSERT INTO chariter (chariter, group_name) VALUES ('402', 'Puerto Rican (260-269)');
INSERT INTO chariter (chariter, group_name) VALUES ('403', 'Cuban (270-274)');
INSERT INTO chariter (chariter, group_name) VALUES ('404', 'Other Hispanic or Latino (200-209, 221-259, 275-299)');
INSERT INTO chariter (chariter, group_name) VALUES ('405', 'Dominican (Dominican Republic) (275-279)');
INSERT INTO chariter (chariter, group_name) VALUES ('406', 'Central American (excludes Mexican) (221-230)');
INSERT INTO chariter (chariter, group_name) VALUES ('407', 'Costa Rican (221)');
INSERT INTO chariter (chariter, group_name) VALUES ('408', 'Guatemalan (222)');
INSERT INTO chariter (chariter, group_name) VALUES ('409', 'Honduran (223)');
INSERT INTO chariter (chariter, group_name) VALUES ('410', 'Nicaraguan (224)');
INSERT INTO chariter (chariter, group_name) VALUES ('411', 'Panamanian (225)');
INSERT INTO chariter (chariter, group_name) VALUES ('412', 'Salvadoran (226)');
INSERT INTO chariter (chariter, group_name) VALUES ('413', 'South American (231-249)');
INSERT INTO chariter (chariter, group_name) VALUES ('414', 'Argentinean (231)');
INSERT INTO chariter (chariter, group_name) VALUES ('415', 'Bolivian (232)');
INSERT INTO chariter (chariter, group_name) VALUES ('416', 'Chilean (233)');
INSERT INTO chariter (chariter, group_name) VALUES ('417', 'Colombian (234)');
INSERT INTO chariter (chariter, group_name) VALUES ('418', 'Ecuadorian (235)');
INSERT INTO chariter (chariter, group_name) VALUES ('419', 'Paraguayan (236)');
INSERT INTO chariter (chariter, group_name) VALUES ('420', 'Peruvian (237)');
INSERT INTO chariter (chariter, group_name) VALUES ('421', 'Uruguayan (238)');
INSERT INTO chariter (chariter, group_name) VALUES ('422', 'Venezuelan (239)');
INSERT INTO chariter (chariter, group_name) VALUES ('423', 'Spaniard (200-209)');
INSERT INTO chariter (chariter, group_name) VALUES ('451', 'White alone, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('452', 'White alone or in combination with one or more other races, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('453', 'Black or African American alone, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('454', 'Black or African American alone or in combination with one or more other races, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('455', 'American Indian and Alaska Native alone, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('456', 'American Indian and Alaska Native alone or in combination with one or more other races, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('457', 'Asian alone, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('458', 'Asian alone or in combination with one or more other races, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('459', 'Native Hawaiian and Other Pacific Islander alone, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('460', 'Native Hawaiian and Other Pacific Islander alone or in combination with one or more other races, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('461', 'Some other race alone, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('462', 'Some other race alone or in combination with one or more other races, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('463', 'Two or more races, not Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('464', 'White alone, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('465', 'White alone or in combination with one or more other races, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('466', 'Black or African American alone, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('467', 'Black or African American alone or in combination with one or more other races, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('468', 'American Indian and Alaska Native alone, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('469', 'American Indian and Alaska Native alone or in combination with one or more other races, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('470', 'Asian alone, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('471', 'Asian alone or in combination with one or more other races, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('472', 'Native Hawaiian and Other Pacific Islander alone, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('473', 'Native Hawaiian and Other Pacific Islander alone or in combination with one or more other races, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('474', 'Some Other Race alone, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('475', 'Some Other Race alone or in combination with one or more other races, Hispanic or Latino');
INSERT INTO chariter (chariter, group_name) VALUES ('476', 'Two or More Races, Hispanic or Latino');
--Ancestry groups
INSERT INTO chariter (chariter, group_name) VALUES ('501', 'Afghan (600)');
INSERT INTO chariter (chariter, group_name) VALUES ('502', 'Albanian (100)');
INSERT INTO chariter (chariter, group_name) VALUES ('573', 'American (939-994)');
INSERT INTO chariter (chariter, group_name) VALUES ('504', 'Arab (400-415, 417-418, 421-430, 435-481, 490-499)');
INSERT INTO chariter (chariter, group_name) VALUES ('300', 'Algerian (400)');
INSERT INTO chariter (chariter, group_name) VALUES ('506', 'Egyptian (402-403)');
INSERT INTO chariter (chariter, group_name) VALUES ('507', 'Iraqi (417-418)');
INSERT INTO chariter (chariter, group_name) VALUES ('508', 'Jordanian (421-422)');
INSERT INTO chariter (chariter, group_name) VALUES ('302', 'Kurdish (442)');
INSERT INTO chariter (chariter, group_name) VALUES ('509', 'Lebanese (425-426)');
INSERT INTO chariter (chariter, group_name) VALUES ('510', 'Moroccan (406-407)');
INSERT INTO chariter (chariter, group_name) VALUES ('511', 'Palestinian (465-467)');
INSERT INTO chariter (chariter, group_name) VALUES ('512', 'Syrian (429-430)');
INSERT INTO chariter (chariter, group_name) VALUES ('301', 'Yemeni (435)');
INSERT INTO chariter (chariter, group_name) VALUES ('505', 'Arab/Arabic (495-499)');
INSERT INTO chariter (chariter, group_name) VALUES ('513', 'Armenian (431-433)');
INSERT INTO chariter (chariter, group_name) VALUES ('514', 'Assyrian/Chaldean/Syriac (482-489)');
INSERT INTO chariter (chariter, group_name) VALUES ('515', 'Australian (800-802)');
INSERT INTO chariter (chariter, group_name) VALUES ('516', 'Austrian (003-004)');
INSERT INTO chariter (chariter, group_name) VALUES ('517', 'Basque (005-007)');
INSERT INTO chariter (chariter, group_name) VALUES ('518', 'Belgian (008-010)');
INSERT INTO chariter (chariter, group_name) VALUES ('519', 'Brazilian (360-364)');
INSERT INTO chariter (chariter, group_name) VALUES ('520', 'British (011-014)');
INSERT INTO chariter (chariter, group_name) VALUES ('521', 'Bulgarian (103)');
INSERT INTO chariter (chariter, group_name) VALUES ('500', 'Cajun (936-938)');
INSERT INTO chariter (chariter, group_name) VALUES ('522', 'Canadian (931-934)');
INSERT INTO chariter (chariter, group_name) VALUES ('523', 'Celtic (099)');
INSERT INTO chariter (chariter, group_name) VALUES ('524', 'Croatian (109-110)');
INSERT INTO chariter (chariter, group_name) VALUES ('525', 'Czech (111-113)');
INSERT INTO chariter (chariter, group_name) VALUES ('526', 'Czechoslovakian (114)');
INSERT INTO chariter (chariter, group_name) VALUES ('527', 'Danish (020, 023)');
INSERT INTO chariter (chariter, group_name) VALUES ('528', 'Dutch (021, 029)');
INSERT INTO chariter (chariter, group_name) VALUES ('529', 'English (015, 022)');
INSERT INTO chariter (chariter, group_name) VALUES ('531', 'European (195)');
INSERT INTO chariter (chariter, group_name) VALUES ('532', 'Finnish (024-025)');
INSERT INTO chariter (chariter, group_name) VALUES ('533', 'French (except Basque) (016, 026-028, 083)');
INSERT INTO chariter (chariter, group_name) VALUES ('534', 'French Canadian (935)');
INSERT INTO chariter (chariter, group_name) VALUES ('535', 'German (032-045)');
INSERT INTO chariter (chariter, group_name) VALUES ('536', 'Greek (046-048)');
INSERT INTO chariter (chariter, group_name) VALUES ('537', 'Guyanese (370-374)');
INSERT INTO chariter (chariter, group_name) VALUES ('538', 'Hungarian (125-126)');
INSERT INTO chariter (chariter, group_name) VALUES ('539', 'Icelander (049)');
INSERT INTO chariter (chariter, group_name) VALUES ('540', 'Iranian (416)');
INSERT INTO chariter (chariter, group_name) VALUES ('541', 'Irish (050, 081)');
INSERT INTO chariter (chariter, group_name) VALUES ('542', 'Israeli (419-420)');
INSERT INTO chariter (chariter, group_name) VALUES ('543', 'Italian (030-031, 051-074)');
INSERT INTO chariter (chariter, group_name) VALUES ('544', 'Latvian (128)');
INSERT INTO chariter (chariter, group_name) VALUES ('545', 'Lithuanian (129)');
INSERT INTO chariter (chariter, group_name) VALUES ('546', 'Luxemburger (077)');
INSERT INTO chariter (chariter, group_name) VALUES ('547', 'Macedonian (130-131)');
INSERT INTO chariter (chariter, group_name) VALUES ('548', 'Maltese (078)');
INSERT INTO chariter (chariter, group_name) VALUES ('549', 'Norwegian (082)');
INSERT INTO chariter (chariter, group_name) VALUES ('550', 'Pennsylvania German (929)');
INSERT INTO chariter (chariter, group_name) VALUES ('551', 'Polish (142-143)');
INSERT INTO chariter (chariter, group_name) VALUES ('552', 'Portuguese (084-086)');
INSERT INTO chariter (chariter, group_name) VALUES ('553', 'Romanian (144-147)');
INSERT INTO chariter (chariter, group_name) VALUES ('554', 'Russian (148-151)');
INSERT INTO chariter (chariter, group_name) VALUES ('555', 'Scandinavian (098)');
INSERT INTO chariter (chariter, group_name) VALUES ('556', 'Scotch-Irish (087)');
INSERT INTO chariter (chariter, group_name) VALUES ('557', 'Scottish (088)');
INSERT INTO chariter (chariter, group_name) VALUES ('558', 'Serbian (152)');
INSERT INTO chariter (chariter, group_name) VALUES ('559', 'Slavic (178-180)');
INSERT INTO chariter (chariter, group_name) VALUES ('560', 'Slovak (153)');
INSERT INTO chariter (chariter, group_name) VALUES ('561', 'Slovene (154-155)');
INSERT INTO chariter (chariter, group_name) VALUES ('562', 'Subsaharan African (500-599)');
INSERT INTO chariter (chariter, group_name) VALUES ('305', 'Cameroonian (508)');
INSERT INTO chariter (chariter, group_name) VALUES ('564', 'Cape Verdean (510-511)');
INSERT INTO chariter (chariter, group_name) VALUES ('306', 'Congolese (515-516)');
INSERT INTO chariter (chariter, group_name) VALUES ('565', 'Ethiopian (522-524)');
INSERT INTO chariter (chariter, group_name) VALUES ('566', 'Ghanaian (529)');
INSERT INTO chariter (chariter, group_name) VALUES ('307', 'Kenyan (534)');
INSERT INTO chariter (chariter, group_name) VALUES ('308', 'Liberian (541)');
INSERT INTO chariter (chariter, group_name) VALUES ('567', 'Nigerian (553-560)');
INSERT INTO chariter (chariter, group_name) VALUES ('309', 'Senegalese (564)');
INSERT INTO chariter (chariter, group_name) VALUES ('310', 'Sierra Leonean (566)');
INSERT INTO chariter (chariter, group_name) VALUES ('311', 'Somalian (568)');
INSERT INTO chariter (chariter, group_name) VALUES ('568', 'South African (570-573)');
INSERT INTO chariter (chariter, group_name) VALUES ('312', 'Sudanese (576-580)');
INSERT INTO chariter (chariter, group_name) VALUES ('563', 'African (599)');
INSERT INTO chariter (chariter, group_name) VALUES ('569', 'Swedish (089-090)');
INSERT INTO chariter (chariter, group_name) VALUES ('570', 'Swiss (091-093, 095-096)');
INSERT INTO chariter (chariter, group_name) VALUES ('571', 'Turkish (434)');
INSERT INTO chariter (chariter, group_name) VALUES ('572', 'Ukrainian (171-174)');
INSERT INTO chariter (chariter, group_name) VALUES ('574', 'Welsh (097)');
INSERT INTO chariter (chariter, group_name) VALUES ('575', 'West Indian (excluding Hispanic origin groups) (300-359)');
INSERT INTO chariter (chariter, group_name) VALUES ('313', 'Antigua and Barbuda (325)');
INSERT INTO chariter (chariter, group_name) VALUES ('576', 'Bahamian (300)');
INSERT INTO chariter (chariter, group_name) VALUES ('577', 'Barbadian (301)');
INSERT INTO chariter (chariter, group_name) VALUES ('578', 'Belizean (302)');
INSERT INTO chariter (chariter, group_name) VALUES ('579', 'British West Indian (321-331)');
INSERT INTO chariter (chariter, group_name) VALUES ('580', 'Dutch West Indian (310-313)');
INSERT INTO chariter (chariter, group_name) VALUES ('314', 'Grenadian (329)');
INSERT INTO chariter (chariter, group_name) VALUES ('581', 'Haitian (336-359)');
INSERT INTO chariter (chariter, group_name) VALUES ('582', 'Jamaican (308-309)');
INSERT INTO chariter (chariter, group_name) VALUES ('316', 'St Lucia Islander (331)');
INSERT INTO chariter (chariter, group_name) VALUES ('583', 'Trinidadian and Tobagonian (314-316)');
INSERT INTO chariter (chariter, group_name) VALUES ('315', 'Vincent-Grenadine Islander (330)');
INSERT INTO chariter (chariter, group_name) VALUES ('584', 'West Indian (335)');
INSERT INTO chariter (chariter, group_name) VALUES ('585', 'Yugoslavian (176-177)');

/*
REPLACE CERTAIN STANDARD DATA IMPORT FUNCTIONS
*/

--join_sequences() MUST ACCOUNT FOR CHARITER FIELD
DROP FUNCTION IF EXISTS join_sequences(text[]);
CREATE FUNCTION join_sequences(seq_id text[]) RETURNS text AS $function$
DECLARE 
	i INT;
	join_clause TEXT := '';
BEGIN	
	join_clause := seq_id[1];
	FOR i IN 2 .. array_upper(seq_id, 1) LOOP
		join_clause := join_clause || ' JOIN ' || seq_id[i] || ' USING (stusab, logrecno, chariter)';
	END LOOP;
	RETURN join_clause;
END;
$function$ LANGUAGE plpgsql;

/*
SEQUENCE IMPORT HAS TO ACCOMMODATE MULTIPLE FILES BY DEMOGRAPHIC GROUP. 
FINAL SCRIPT IS VERY LARGE, SO BREAK INTO SEPARATE FILES BY STATE.

TABLE STORAGE FUNCTIONS IN SEPARATE SCRIPT.
*/
DROP FUNCTION IF EXISTS sql_import_sequences(boolean, text[], int[], text);  
CREATE FUNCTION sql_import_sequences(exec boolean = FALSE, stusab_criteria text[] = ARRAY['%'], 
	seq_criteria int[] = ARRAY[-1], actions text = 'em'
	) RETURNS text AS $sql_import_sequences$
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
	SELECT 
		array_to_string(array_agg(sql1), E'\n'),
		array_to_string(array_agg(sql2), E'\n')
	INTO 	sql_estimate, sql_moe
	FROM (
		SELECT
			'COPY tmp_' || seq_id || E' FROM \''
			|| get_census_upload_root() || '/' || current_schema || '/e20105'
			|| stusab || lpad(seq::varchar, 4, '0') || chariter || E'.txt\' WITH CSV;'
			AS sql1,
			'COPY tmp_' || seq_id || E'_moe FROM \''
			|| get_census_upload_root() || '/' || current_schema || '/m20105'
			|| stusab || lpad(seq::varchar, 4, '0') || chariter || E'.txt\' WITH CSV;'
			AS sql2
		FROM	stusab, vw_sequence, chariter
		WHERE	stusab ILIKE ANY (stusab_criteria) AND seq = ANY (seq_criteria2)
		ORDER BY stusab, seq_id, chariter
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

	IF exec THEN EXECUTE sql; END IF;
	RETURN sql;
END;
$sql_import_sequences$ LANGUAGE plpgsql;

/*
--FOLLOWING STATEMENT GENERATES ONE IMPORT SCRIPT PER STATE
--REQUIRES exec() FUNCTION

SELECT exec($$COPY (SELECT 'SET search_path = $$ || current_schema || $$; ' || sql_import_sequences(FALSE, ARRAY['$$ || stusab || $$'])) TO '$$ || get_census_upload_root() || $$/$$ || current_schema || $$/import_sequences_$$ || stusab || $$.sql' WITH CSV QUOTE ' ';$$)	
FROM stusab

*/