SET search_path = acs2010_spt;
SET client_encoding = 'LATIN1';

DROP TABLE IF EXISTS tmp_geoheader;
CREATE TABLE tmp_geoheader (
	all_fields varchar
)
WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE)
;

COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ak.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105al.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ar.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105az.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ca.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105co.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ct.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105dc.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105de.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105fl.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ga.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105hi.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ia.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105id.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105il.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105in.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ks.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ky.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105la.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ma.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105md.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105me.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105mi.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105mn.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105mo.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ms.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105mt.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105nc.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105nd.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ne.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105nh.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105nj.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105nm.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105nv.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ny.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105oh.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ok.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105or.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105pa.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105pr.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ri.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105sc.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105sd.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105tn.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105tx.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105us.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105ut.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105va.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105vt.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105wa.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105wi.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105wv.txt';
COPY tmp_geoheader FROM '/<census_upload_root>/acs2010_spt/g20105wy.txt';

CREATE TABLE geoheader (
	fileid varchar(6),
	stusab varchar(2),
	sumlevel int,
	component varchar(2),
	logrecno int,
	us varchar(1),
	region varchar(1),
	division varchar(1),
	statece varchar(2),
	state varchar(2),
	county varchar(3),
	cousub varchar(5),
	place varchar(5),
	tract varchar(6),
	blkgrp varchar(1),
	concit varchar(5),
	aianhh varchar(4),
	aianhhfp varchar(5),
	aihhtli varchar(1),
	aitsce varchar(3),
	aits varchar(5),
	anrc varchar(5),
	cbsa varchar(5),
	csa varchar(3),
	metdiv varchar(5),
	macc varchar(1),
	memi varchar(1),
	necta varchar(5),
	cnecta varchar(3),
	nectadiv varchar(5),
	ua varchar(5),
	blank1 varchar(5),
	cdcurr varchar(2),
	sldu varchar(3),
	sldl varchar(3),
	blank2 varchar(6),
	blank3 varchar(3),
	blank4 varchar(5),
	submcd varchar(5),
	sdelm varchar(5),
	sdsec varchar(5),
	sduni varchar(5),
	ur varchar(1),
	pci varchar(1),
	blank5 varchar(6),
	blank6 varchar(5),
	puma5 varchar(5),
	blank7 varchar(5),
	geoid varchar(40),
	name varchar(200),
	bttr varchar(6),
	btbg varchar(1),
	blank8 varchar(43),
	PRIMARY KEY (stusab, logrecno)
)
WITH (autovacuum_enabled = FALSE, toast.autovacuum_enabled = FALSE);

COMMENT ON COLUMN geoheader.fileid IS 'Always equal to ACS Summary File identification';
COMMENT ON COLUMN geoheader.stusab IS 'State Postal Abbreviation';
COMMENT ON COLUMN geoheader.sumlevel IS 'Summary Level';
COMMENT ON COLUMN geoheader.component IS 'Geographic Component';
COMMENT ON COLUMN geoheader.logrecno IS 'Logical Record Number';
COMMENT ON COLUMN geoheader.us IS 'US';
COMMENT ON COLUMN geoheader.region IS 'Census Region';
COMMENT ON COLUMN geoheader.division IS 'Census Division';
COMMENT ON COLUMN geoheader.statece IS 'State (Census Code)';
COMMENT ON COLUMN geoheader.state IS 'State (FIPS Code)';
COMMENT ON COLUMN geoheader.county IS 'County of current residence';
COMMENT ON COLUMN geoheader.cousub IS 'County Subdivision (FIPS)';
COMMENT ON COLUMN geoheader.place IS 'Place (FIPS Code)';
COMMENT ON COLUMN geoheader.tract IS 'Census Tract';
COMMENT ON COLUMN geoheader.blkgrp IS 'Block Group';
COMMENT ON COLUMN geoheader.concit IS 'Consolidated City';
COMMENT ON COLUMN geoheader.aianhh IS 'American Indian Area/Alaska Native Area/ Hawaiian Home Land (Census)';
COMMENT ON COLUMN geoheader.aianhhfp IS 'American Indian Area/Alaska Native Area/ Hawaiian Home Land (FIPS)';
COMMENT ON COLUMN geoheader.aihhtli IS 'American Indian Trust Land/ Hawaiian Home Land Indicator';
COMMENT ON COLUMN geoheader.aitsce IS 'American Indian Tribal Subdivision (Census)';
COMMENT ON COLUMN geoheader.aits IS 'American Indian Tribal Subdivision (FIPS)';
COMMENT ON COLUMN geoheader.anrc IS 'Alaska Native Regional Corporation (FIPS)';
COMMENT ON COLUMN geoheader.cbsa IS 'Metropolitan and Micropolitan Statistical Area';
COMMENT ON COLUMN geoheader.csa IS 'Combined Statistical Area';
COMMENT ON COLUMN geoheader.metdiv IS 'Metropolitan Statistical Area-Metropolitan Division';
COMMENT ON COLUMN geoheader.macc IS 'Metropolitan Area Central City';
COMMENT ON COLUMN geoheader.memi IS 'Metropolitan/Micropolitan Indicator Flag';
COMMENT ON COLUMN geoheader.necta IS 'New England City and Town Area';
COMMENT ON COLUMN geoheader.cnecta IS 'New England City and Town Combined Statistical Area';
COMMENT ON COLUMN geoheader.nectadiv IS 'New England City and Town Area Division';
COMMENT ON COLUMN geoheader.ua IS 'Urban Area';
COMMENT ON COLUMN geoheader.blank1 IS 'Reserved for future use';
COMMENT ON COLUMN geoheader.cdcurr IS 'Current Congressional District ***';
COMMENT ON COLUMN geoheader.sldu IS 'State Legislative District Upper';
COMMENT ON COLUMN geoheader.sldl IS 'State Legislative District Lower';
COMMENT ON COLUMN geoheader.blank2 IS 'Reserved for future use';
COMMENT ON COLUMN geoheader.blank3 IS 'Reserved for future use';
COMMENT ON COLUMN geoheader.blank4 IS 'Reserved for future use';
COMMENT ON COLUMN geoheader.submcd IS 'Subminor Civil Division (FIPS)';
COMMENT ON COLUMN geoheader.sdelm IS 'State-School District (Elementary)';
COMMENT ON COLUMN geoheader.sdsec IS 'State-School District (Secondary)';
COMMENT ON COLUMN geoheader.sduni IS 'State-School District (Unified)';
COMMENT ON COLUMN geoheader.ur IS 'Urban/Rural';
COMMENT ON COLUMN geoheader.pci IS 'Principal City Indicator';
COMMENT ON COLUMN geoheader.blank5 IS 'Reserved for future use';
COMMENT ON COLUMN geoheader.blank6 IS 'Reserved for future use';
COMMENT ON COLUMN geoheader.puma5 IS 'Public Use Microdata Area - 5% File';
COMMENT ON COLUMN geoheader.blank7 IS 'Reserved for future use';
COMMENT ON COLUMN geoheader.geoid IS 'Geographic Identifier';
COMMENT ON COLUMN geoheader.name IS 'Area Name';
COMMENT ON COLUMN geoheader.bttr IS 'Tribal Tract';
COMMENT ON COLUMN geoheader.btbg IS 'Tribal Block Group';
COMMENT ON COLUMN geoheader.blank8 IS 'Reserved for future use';

INSERT INTO geoheader SELECT
	btrim(substring(all_fields from 1 for 6)) AS fileid,
	btrim(substring(all_fields from 7 for 2)) AS stusab,
	btrim(substring(all_fields from 9 for 3))::int AS sumlevel,
	btrim(substring(all_fields from 12 for 2)) AS component,
	btrim(substring(all_fields from 14 for 7))::int AS logrecno,
	NULLIF(btrim(substring(all_fields from 21 for 1)), '') AS us,
	NULLIF(btrim(substring(all_fields from 22 for 1)), '') AS region,
	NULLIF(btrim(substring(all_fields from 23 for 1)), '') AS division,
	NULLIF(btrim(substring(all_fields from 24 for 2)), '') AS statece,
	NULLIF(btrim(substring(all_fields from 26 for 2)), '') AS state,
	NULLIF(btrim(substring(all_fields from 28 for 3)), '') AS county,
	NULLIF(btrim(substring(all_fields from 31 for 5)), '') AS cousub,
	NULLIF(btrim(substring(all_fields from 36 for 5)), '') AS place,
	NULLIF(btrim(substring(all_fields from 41 for 6)), '') AS tract,
	NULLIF(btrim(substring(all_fields from 47 for 1)), '') AS blkgrp,
	NULLIF(btrim(substring(all_fields from 48 for 5)), '') AS concit,
	NULLIF(btrim(substring(all_fields from 53 for 4)), '') AS aianhh,
	NULLIF(btrim(substring(all_fields from 57 for 5)), '') AS aianhhfp,
	NULLIF(btrim(substring(all_fields from 62 for 1)), '') AS aihhtli,
	NULLIF(btrim(substring(all_fields from 63 for 3)), '') AS aitsce,
	NULLIF(btrim(substring(all_fields from 66 for 5)), '') AS aits,
	NULLIF(btrim(substring(all_fields from 71 for 5)), '') AS anrc,
	NULLIF(btrim(substring(all_fields from 76 for 5)), '') AS cbsa,
	NULLIF(btrim(substring(all_fields from 81 for 3)), '') AS csa,
	NULLIF(btrim(substring(all_fields from 84 for 5)), '') AS metdiv,
	NULLIF(btrim(substring(all_fields from 89 for 1)), '') AS macc,
	NULLIF(btrim(substring(all_fields from 90 for 1)), '') AS memi,
	NULLIF(btrim(substring(all_fields from 91 for 5)), '') AS necta,
	NULLIF(btrim(substring(all_fields from 96 for 3)), '') AS cnecta,
	NULLIF(btrim(substring(all_fields from 99 for 5)), '') AS nectadiv,
	NULLIF(btrim(substring(all_fields from 104 for 5)), '') AS ua,
	NULLIF(btrim(substring(all_fields from 109 for 5)), '') AS blank1,
	NULLIF(btrim(substring(all_fields from 114 for 2)), '') AS cdcurr,
	NULLIF(btrim(substring(all_fields from 116 for 3)), '') AS sldu,
	NULLIF(btrim(substring(all_fields from 119 for 3)), '') AS sldl,
	NULLIF(btrim(substring(all_fields from 122 for 6)), '') AS blank2,
	NULLIF(btrim(substring(all_fields from 128 for 3)), '') AS blank3,
	NULLIF(btrim(substring(all_fields from 131 for 5)), '') AS blank4,
	NULLIF(btrim(substring(all_fields from 136 for 5)), '') AS submcd,
	NULLIF(btrim(substring(all_fields from 141 for 5)), '') AS sdelm,
	NULLIF(btrim(substring(all_fields from 146 for 5)), '') AS sdsec,
	NULLIF(btrim(substring(all_fields from 151 for 5)), '') AS sduni,
	NULLIF(btrim(substring(all_fields from 156 for 1)), '') AS ur,
	NULLIF(btrim(substring(all_fields from 157 for 1)), '') AS pci,
	NULLIF(btrim(substring(all_fields from 158 for 6)), '') AS blank5,
	NULLIF(btrim(substring(all_fields from 164 for 5)), '') AS blank6,
	NULLIF(btrim(substring(all_fields from 169 for 5)), '') AS puma5,
	NULLIF(btrim(substring(all_fields from 174 for 5)), '') AS blank7,
	NULLIF(btrim(substring(all_fields from 179 for 40)), '') AS geoid,
	NULLIF(btrim(substring(all_fields from 219 for 200)), '') AS name,
	NULLIF(btrim(substring(all_fields from 419 for 6)), '') AS bttr,
	NULLIF(btrim(substring(all_fields from 425 for 1)), '') AS btbg,
	NULLIF(btrim(substring(all_fields from 426 for 43)), '') AS blank8
FROM tmp_geoheader