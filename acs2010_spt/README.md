# Overview

This set of scripts will create database structures necessary to store the American Community Survey (ACS) 2010 Selected Population Tables in a PostgreSQL database. The scripts are part of the census-postgres project. There are two types of scripts:

1. Scripts which create the necessary data schema, bulk load the data to import tables, and coerce it to final form;
2. Meta-scripts, scripts which create functions which generate the schema creation and data import scripts.

This folder contains all the necessary data import scripts (the first kind of script). Most of these scripts are created by meta-scripts (the second kind of script) which are part of the main project, and are contained in the census-postgres/meta-scripts folder. Some of the meta-scripts had to be modified to account for differences from other US Census data products. For example, in the "standard" ACS, each row is uniquely identied by the state and record number (`stusab` and `logrecno`). In the Selected Population Tables data project, the ethnic or racial group code (`chariter`) is needed as well.  

The data manager has the choice of running the data import scripts directly, or of running the meta-scripts first. If the meta-scripts are run, each script creation functions can be called with the execute parameter set to TRUE (see the section "Standard Function Parameters"), which will programatically create and immediately execute the generated script. The first option is probably conceptually easier to understand. The second option is more powerful, as it gives the data manager more control over the import process (for example, only importing certain states or sequences--the same effect using the data import scripts requires searching the script for specific lines of code to execute or exclude).

# Running the Data Scripts

The data scripts should be run in a specific order. They will generate storage tables, staging (temp) tables, and views which mirror Census "subject tables", as well as actually doing the data import.

*Table and view names in these scripts are* ***not*** *schema-qualified.* Each script begins with 

```sql
SET search_path = acs2010_spt;
```

If another schema name is desired, the statement needs to be altered. Note that unlike the general practice in the census-postgres project, the schema name is not an exact match for the US Census FTP folder name. This is because the acs2010_spt_aian folder contains two subfolders with slightly different data products, the Selected Population Tables and American Indian Alaska Native Tables. These scripts have only been tested on the Selected Population Tables, hence acs2010_spt.

## Geoheader

In order to reduce the number of separate scripts which need to be run (compared with the parent project), all steps necessary to create the data structures and import the geoheader data have been combined into one script:

* geoheader_all_steps.sql

The script contains a COPY statement for each state (plus DC and Puerto Rico). If not importing all states, run only the desired lines (or comment out undesired lines). The general process follows the same pattern as importing the sequences, so read the following sections for more details.

## Create Staging Tables

DROP and CREATE TABLE scripts are separated so that half-loaded datasets won't accidentally be deleted, and so that data can be loaded in batches. Work process might be to import an entire state or group of states into the staging tables, push data into final storage tables, then drop all the staging tables. When importing another batch, recreate the staging tables.

These scripts may be run in any order.

* drop_import_tables.sql
* create_import_tables.sql

## Import Data

These scripts use COPY statements to do the actual data import, albeit to staging tables, not to the final destination. COPY requires that the files be on the server's own filesystem (unlike psql \copy). Since these datasets are large, this is probably a good idea anyway.

The ACS 2010 Selected Population Tables data product is released as an extremely large number of small files (many of which contain no data because of suppression). The total dataset is over 1.5 million files, which means that a full import script would have over 1.5 million lines of code (each line with one COPY statements). Such a large file will be quite unwieldy to work with, particularly if the data manager is only importing selected states. This folder therefore contains only state-specific scripts. Anyone wishing to attempt to import all states at once should make use of the meta-scripts.

These scripts use forward slashes to represent filesystem separators. Testing on Windows Vista indicates that forward slashes will be interpreted correctly. Backslashes, if used, are treated as escape characters and would need to be doubled.

These scripts contain a filesystem placeholder "<census_upload_root>". This placeholder should be updated to reflect your filesystem. The upload root folder should have a child named acs2010_spt. 

The meta-scripts make it easier to import selected sequences, or to import only estimates or margins of error. If using the data import scripts instead of the meta-scripts, the data manager will have to manually select the sequences desired from these files.

* import_sequences_XX.sql (individual states by two-character postal code, including DC, PR, and US)

## Create Data Store

Researchers will typically interact with the data via a "subject table" a collection of related data. Groups of related subject tables are distributed in "sequence" files. Often a subject table will break down the population into categories (e.g. age and sex) and include summary columns (e.g. total population, male population, female population). The data are stored by sequences (that is, each sequence is stored in its own database table), so subject tables are constructed as views.

### Create Table-based Data Store

The CREATE TABLE scripts rely upon the existence of geoheader (using the LIKE keyword), so geoheader_all_steps.sql should already have been run (or at least the lines that create the geoheader table, whether or not geoheader data has been imported).

These scripts create two tables for each sequence, one with estimates (named seqnnnn), and one with margins of error (named seqnnnn_moe). Column names are unique (margin of error tables have _moe at the end of column names) except for key fields so that the tables can be joined without conflict or confusion. The store_* scripts must be run first. The view_* and insert_* scripts can be run in any order.

1. store_by_tables.sql
2. insert_into_tables.sql
3. view_estimate_stored_by_tables.sql
4. view_moe_stored_by_tables.sql

# Using Functions to Create the Data Store and Import Data

The data scripts from the last section were created programmatically using several helper functions that build the SQL based on the Census product's data dictionary. Most of these helper functions are part of the general census-postgres project, while some are specific to the ACS 2010 Selected Population Tables data product. The general meta-scripts (function-creating scripts) are:

* Support Functions and Tables.sql
* Staging Tables and Data Import Functions.sql
* Geoheader.sql
* Data Store Table-Based.sql

These scripts are described in the general project readme. The support functions and meta-scripts unique to the ACS 2010 SPT are included in:

* ACS 2010 Selected Population Tables Data Dictionary.sql
* Data Store Table-Based.sql

It is assumed that the *general* meta-scripts have been run in the public schema. The SPT-specific meta-scripts create functions which duplicate the names of the analogous functions in the general project. These functions (for example, sql_store_by_tables())should be called within the acs2010_spt schema, in which case they will be "seen" prior to the analogous function in the public schema.

In general, the order in which these scripts are run is not that important. Some of the user functions do refer to other user functions, but Postgres will create the function regardless and won't throw an error until the function with the dependecy is called.

The functions and support tables are documented only where their usage diverges from the equivalently named function in the general census-postgres project. 

## ACS 2010 Selected Population Tables Data Dictionary.sql

In addition to containing the commands to import the data dictionary for this Census product, this script also contains two product-specific functions which alter the standard functions. In addition, note that the copy of Sequence_Number_and_Table_Number_Lookup.txt included in this project has been modified from the US Census Bureau version. Quoted empty strings ("") and dots (".") have been stripped to allow NULLs to be imported correctly. The function sql_import_data_dictionary() is nonetheless called in the standard manner.

    join_sequences(seq_id text array)

seq_id: An array of sequence/segment names.

Given an array of sequence/segment names, creates a JOIN clause using the stusab,  logrecno, and chariter fields. Used for multi-sequence/segment subject tables. Called by various data functions, not usually called by the user.

    sql_import_sequences([exec boolean[, stusab_criteria text array[, seq_criteria int array [, actions text]]]])

Imports the sequence files to the estimate staging tables and the margin of error staging tables. The first three parameters are explained above. The actions parameter determines what part of the entire Census dataset to import (or generate scripts for). The parameter is inspected for the letters e and m, in any order.

e: Indicates to import the estimates.
m: Indicates to import the margins of error.

Other letters are ignored. The data product does not split the data into large and small geographies, so the a and t switches are ignored. If the parameter is omitted, both estimates and margins of error will be imported.

## Standard Function Parameters

(This is a copy of the same section from the general project readme.)

Parameters used by several different functions are detailed here. For the SQL-generating functions, the first (optional) parameter is always a boolean named exec, which controls whether the SQL is immediately executed after being generated. If called with no parameters, exec = FALSE is assumed, i.e. the generated script is not executed. Additional parameters control additional options. The generated SQL statement, whether executed or not, is returned to the client in a (sometimes very long) text string.

exec: Execute SQL immediately after it is generated. Defaults to FALSE.

stusab_criteria: An array of state two-letter postal codes (in either upper or lower case) indicating which geoheader files to import. Defaults to all states, including Puerto Rico. State codes can include wild cards. For example, this imports New York (NY) and all states that begin with W (WA, WI, WV, WY):

    SELECT sql_import_geoheader(TRUE, ARRAY['ny', 'w%']);

You can also query stusab to choose an alphabetic range of states, or to specify states by exclusion (useful if you want most but not all states). For example, keeping in mind that 'm' is "less than" any two-letter code beginning with 'm', this will get all states from Alaska (AK) to Lousiana (LA):

    SELECT sql_import_geoheader(TRUE, 
      (SELECT array_agg(stusab) FROM stusab WHERE stusab BETWEEN 'a' AND 'm')
      );

While the parameter defaults to all states, to use additional optional parameters, all states can be specified by ARRAY['%'].

seq_criteria int: An array of sequence/segment numbers. Defaults to all sequences/segments. To specify a range of sequnces, use generate_series(begin, end):

    SELECT sql_import_sequences(TRUE, ARRAY['%'], (SELECT array_agg(generate_series) FROM generate_series(1, 10)));

To specify all sequences explicitly, use (SELECT array_agg(seq) FROM vw_sequence).

## Data Store Table-Based.sql

The functions in this meta-script are called in exactly the same manner as the standard versions. Note, however, that the result is slightly different, as they create tables with a PRIMARY KEY of stusab, logrecno, and chariter. (The standard versions do not need, and in fact cannot use, chariter, which is NULL in most US Census data products.) 

# Running the Data Functions from Start to Finish

The general procedure is:

1. Run the meta-scripts (previous section). These create functions and support tables. This only needs to be done once, laying the ground for import of multiple Census products.
2. Run set_census_upload_root(). This also only needs to be run once, as long as you download each data product to a subfolder of this root.
3. Create the schema to hold your data (e.g. acs2010_spt). Change the search_path to that schema.
4. Run the data dictionary functions (next subsection). These functions create tables and views which hold support information relevant to a specific data product, including field names of the geoheader, sequences/segments, and subject tables.
5. Run the data functions. These generate (and optionally execute) the scripts listed in the previous section. They must be run in a specific order.

## The Product-Specific Data Dictionary Script

Each product has a product-specific script which imports the data dictionary and creates some views based on the data dictionary. The data dictionary for this data product is created by "ACS 2010 Selected Population Tables Data Dictionary.sql". This script

1. Creates a schema named acs2010_spt (uncomment line to execute).
2. Creates a geoheader_schema table. The geoheader changes from product to product, so the schema is a list of field names and start and end positions, allowing the creation of a geoheader table with the appropriate structure and the parsing of the fixed length geoheader files.
3. Creates the data_dictionary table.
4. Imports the data dictionary file from <census_upload_root>/acs2010_spt.
5. Creates views which extract the sequences, subject tables, and subject table cells from data_dictionary.

## Run the Data Functions

If (a) the meta-scripts have been run, generating all necessary data functions, and (b) the product-specific data dictionary has been imported, then the data functions will actually create (and optionally run) the SQL statements to create the necessary data structures and import the data. They should be run in this order:

```sql
SET search_path = acs2010_spt, public;
SET client_encoding = 'LATIN1';
SELECT sql_create_tmp_geoheader(TRUE);
SELECT sql_import_geoheader(TRUE); --Imports all states
SELECT sql_create_import_tables(TRUE);
SELECT sql_import_sequences(TRUE); --Imports margins of error and estimates for all states and sequences
SELECT sql_create_geoheader(TRUE);
SELECT sql_geoheader_comments(TRUE);
SELECT sql_store_by_tables(TRUE);
SELECT sql_view_estimate_stored_by_tables(TRUE);
SELECT sql_view_moe_stored_by_tables(TRUE);
SELECT sql_parse_tmp_geoheader(TRUE); --Copies all data from tmp_geoheader to geoheader
SELECT sql_insert_into_tables(TRUE); --Copies all estimates and margins of error to sequence tables
```

Note that the functions sql_import_sequences() and sql_insert_into_tables() will take a long time to execute. The SPT data product is not as large as the entire Decennial Census or standard ACS, so it will probably execute faster than those imports, but probably will still take an overnight. These can be speeded up by using the parameters to do only certain states or sequences in various batches. As I experiment, I may come up with better faster ways to do this. If you are running Postgres 9.1, you can speed up import by altering sql_create_import_tables() to create UNLOGGED tables (http://www.postgresql.org/docs/9.1/interactive/sql-createtable.html). If you are not using Postgres 9.1, logging can be avoided if the staging table is created or truncated prior to import, and the COPY statements are part of the same transaction, i.e. The functions as currently written do not make this easy to do.

# Closing

For comments, or if you are interested in assisting, please feel free to contact me at Lee.Hachadoorian@gmail.com

These scripts are released under the GNU General Public License.

















