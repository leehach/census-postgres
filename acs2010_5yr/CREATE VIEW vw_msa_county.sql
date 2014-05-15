DROP VIEW IF EXISTS acs2010_5yr.vw_msa_county;
CREATE VIEW acs2010_5yr.vw_msa_county AS
select stusab, name AS cbsa_name, state || county AS fips, cbsa,
	CASE WHEN name like '%Metro Area%' THEN 'metro'
		WHEN NAME LIKE '%Micro Area%' THEN 'micro'
		ELSE NULL
	END AS metro_micro
from acs2010_5yr.geoheader where sumlevel = 322
;

--SELECT * FROM acs2010_5yr.geoheader WHERE sumlevel = 320 and name ilike 'New York%'