# Notes on ACS 2011

The file Sequence_Number_and_Table_Number_Lookup.txt is modified from the version downloaded from the Census website. The Census version contains quoted periods (.) and quoted empty strings, which together make standard COPY-based CSV import impossible, as there are two possible NULL values. The version included in this git should be used instead to create acs2011_5yr.data_dictionary in Postgres.

The file ACS_2007_2011_SF_Tech_Doc.pdf is the same one provided by the Census. 
