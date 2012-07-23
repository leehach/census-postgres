# Overview

This project consists of a number of SQL scripts and other supporting files for importing some recent US Census datasets into a PostgreSQL database. The datasets of interest are the Decennial Census and the annual American Community Survey (ACS). There are two types of scripts:

1. Scripts which create the necessary data schema, bulk load the data to import tables, and coerce it to final form;
2. Meta-scripts, scripts which create functions which generate the schema creation and data import scripts.

My desire is to eventually make the schema creation and data import scripts (the first kind of script) conform to the SQL standard, so that they could be used in other SQL implementations than Postgres. As the meta-scripts (the second kind of script) rely upon PL/pgSQL, I doubt they could be converted to implementation-agnostic. I would be more likely to rewrite them in Python or another language.

The data manager has the choice of running the data import scripts directly, or of running the meta-scripts first. If the meta-scripts are run, each script creation functions can be called with the execute parameter set to TRUE (see the section "Standard Function Parameters"), which will programatically create and immediately execute the generated script. The first option is probably conceptually easier to understand. The second option is more powerful, as it gives the data manager more control over the import process (for example, only importing certain states or sequences--the same effect using the data import scripts requires searching the script for specific lines of code to execute or exclude).

# Getting the Data

Instructions for obtaining the data via FTP to appear here.

Each data product (e.g. American Community Survey 2006-2010) can be thought of as one large file, but the data are horizontally partitioned by state and are vertically separated into "segments" (in the Decennial Census) or "sequences" (in ACS) of less than 256 columns each. This makes for an extremely large number of tables that have to be bulk loaded. These import routines assume that all Decennial Census files will be staged in a single directory. The ACS data are separated into large and small geographies, *but file names are reused for both the large and the small geographies*. In order to distinguish between them, the import routines assume that the two types of files are separated into a directories named All_Geographies_Not_Tracts_Block_Groups and Tracts_Block_Groups_Only. In each case, the parent directory name must match the name of the database schema where the data will be stored. I name the schemas after the datasets folder name on the Census Bureau FTP server, e.g. acs2010_5yr.

# Running the Data Scripts

The data scripts should be run in a specific order. They will generate storage tables, staging (temp) tables, and views which mirror Census "subject tables", as well as actually doing the data import.

*Table and view names in these scripts are* ***not*** *schema-qualified,* allowing the data manager to choose their own schema name. As mentioned above, I use a schema name based on folder names from the Census Bureau FTP server. Assuming you do the same, each script needs to prepended with 

    SET search_path = acs2010_5yr, public; --or other appropriate schema name

If you want to avoid altering each script, SET search_path once in psql, then \i each script file.

## Create Staging Tables

DROP and CREATE TABLE scripts are separated so that half-loaded datasets won't accidentally be deleted, and so that data can be loaded in batches. Work process might be to import an entire state or group of states into the staging tables, push data into final storage tables, then drop all the staging tables. When importing another batch, recreate the staging tables.

These scripts may be run in any order.

* create_tmp_geoheader.sql (contains DROP … IF EXISTS statement)
* drop_import_tables.sql
* create_import_tables.sql
* drop_import_moe.sql
* create_import_moe.sql

## Import Data

These scripts use COPY statements to do the actual data import, albeit to staging tables, not to the final destination. COPY requires that the files be on the server's own filesystem (unlike psql \copy). Since these datasets are large, this is probably a good idea anyway.

These scripts use forward slashes to represent filesystem separators. Testing on Windows Vista indicates that forward slashes will be interpreted correctly. Backslashes, if used, are treated as escape characters and would need to be doubled.

These scripts contain a filesystem placeholder "<census_upload_root>". This placeholder should be updated to reflect your filesystem. This folder should have a child named acs2010_5yr. The acs2010_5yr folder should have two children. As mentioned above, the files downloaded from Census should be in two sibling directories named All_Geographies_Not_Tracts_Block_Groups and Tracts_Block_Groups_Only. 

The geoheader files use a fixed-length format, and are therefore imported to a table with a single column. This column is then parsed for insertion the the final geoheader table. The geoheader files contain *all* geographies, in spite of whether they are downloaded with the larger or smaller (tracts and block groups only) datasets. These scripts assume the existence of the All_Geographies_Not_Tracts_Block_Groups folder. If you have only downloaded the tracts and block groups, you will have to modify the script or create the expected folder and move the geography files (g20105xx.txt).

Meta-scripts (to be released later) will make it easier to import selected states or sequences. For now, the data manager will have to manually select the states and sequences desired from these files.

These scripts may be run in any order.

* import_geoheader.sql
* import_sequences.sql

## Create Data Store

At the moment I am experimenting with three different storage formats. The only one that is completed stores each sequence in its own database table. The other two options combine all the sequences into one table, but, because of Postgres' limit of ~2000 columns in a table, use array columns (one per sequence) or one hstore column to store the data. For information on the status of these options, see below.

Researchers will typically interact with the data via a "subject table" a collection of related data. Often a subject table will break down the population into categories (e.g. age and sex) and include summary columns (e.g. total population, male population, female population). The data are stored by sequences (except for hstore, which pushes the entire dataset into two columns), so subject tables are constructed as views. The view definitions will of course depend upon which data storage method is chosen. **Currently, views are only defined for the table-based data store.**

### Create Geoheader

If following the one-big-table approach, the geoheader columns appear as the first columns in those tables. Nonetheless, the CREATE TABLE scripts rely upon the existence of geoheader (using the LIKE keyword), so create_geoheader.sql should be run in any event.

* create_geoheader.sql

After running, tmp_geoheader may be TRUNCATEd or DROPped, so that when additional data is imported, parse_tmp_geoheader.sql does not attempt to create duplicate records (which will fail due to PRIMARY KEY violation).

### Create Table-based Data Store

These scripts create two tables for each sequence, one with estimates (named seqnnnn), and one with margins of error (named seqnnnn_moe). Column names are unique (margin of error tables have _moe at the end of column names) except for key fields so that the tables can be joined without conflict or confusion. These scripts must be run in this order.

Parse_tmp_geoheader.sql may be run at any time. The other scripts must be run in order.

* parse_tmp_geoheader.sql
1. store_by_tables.sql
2. store_moe_by_tables.sql
3. insert_into_tables.sql
4. insert_into_moe.sql
5. view_estimate_stored_by_tables.sql
6. view_moe_stored_by_tables.sql

### Create Array Column-based Data Store

At the moment, the array column table is named by_arrays. When this project moves past the experimental phase, a less silly name will be chosen. First, create the table. This table will have no rows until parse_tmp_geoheader is run, modified to INSERT INTO by_arrays. Then the sequences can be inserted, using UPDATE to match the sequence data with existing geoheader data. Margin of error data is not yet handeld.

1. store_by_array_columns.sql
2. parse_tmp_geoheader.sql
3. insert_into_array_columns.sql

### Create Hstore Column-based Data Store

At the moment, the hstore table is named by_hstore. When this project moves past the experimental phase, a less silly name will be chosen. First, create the table. This table will have no rows until parse_tmp_geoheader is run, modified to INSERT INTO by_hstore. Unlike with by_arrays, no script currently exists to insert sequence data. As with by_arrays, the script will use UPDATE to match the sequence data with existing geoheader data.

1. store_by_hstore.sql
2. parse_tmp_geoheader.sql
3. insert_into_hstore.sql **Does not yet exist**


# Using Functions to Create the Data Store and Import Data

The data scripts from the last section were created programmatically using several helper functions that build the SQL based on the Census product's data dictionary. The meta-scripts (function-creating scripts) are:

* Support Functions and Tables.sql
* Staging Tables and Data Import Functions.sql
* Geoheader.sql
* Data Store Table-Based.sql
* Data Store Array-Based.sql
* Data Store Hstore-Based.sql

The meta-scripts are set up to run in the public schema, so that they can be called without qualification. If you prefer to keep these functions segregated in their own schema (e.g., census), you will later have to set the appropriate search_path or call them using a schema-qualified name (e.g. census.sql_import_geoheader()).

In general, the order in which these scripts are run is not that important. Some of the user functions do refer to other user functions, but Postgres will create the function regardless and won't throw an error until the function with the dependecy is called. They are separated into these six files of related functions primarily for bookkeeping purposes. Only one of the Data Store scripts needs to be run (i.e., one of the last three scripts). Running all three is harmless, as they merely create the functions which will create the data stores.

The actual functions and support tables are documented in this section's subsections. In the function definition, brackets ([]) indicate optional parameters. For most of the following scripts, all parameters are optional. However, in order to specify a parameter, all earlier parameters must be explicitly given, even if the default value is desired.

## Support Functions and Tables.sql

These functions are created by "Support Functions and Tables.sql".

    set_census_upload_root(upload_root text)

This function sets the root for all Census data staged for uploading. The user needs to call this function once, unless the folder hierarchy changes. The import scripts use the COPY command, so the upload_root must be on the database server, not the client. The path should be named with forward slashes, even on a Windows machine, and there should be no terminal slash (e.g. 'C:/Data/Census'). It is assumed that specific Census products will appear in subfolders matching the schema name you want to use in your database, e.g. acs2010_5yr, census_2010.

    get_census_upload_root()

Returns the path to the root folder, set by set_census_upload_root(). Called by various data functions, not usually called by the user.

    join_sequences(seq_id text array)

seq_id: An array of sequence/segment names.

Given an array of sequence/segment names, creates a JOIN clause using the stusab and logrecno fields. Used for multi-sequence/segment subject tables. Called by various data functions, not usually called by the user.

    sql_import_data_dictionary([filename text])

filename: The name of the data dictionary file. Defaults to Sequence_Number_and_Table_Number_Lookup.txt. 

Imports the data dictionary file to a table named data_dictionary (created separately) in the current schema. The file is expected to be found in the path /upload_root/current_schema.

    CREATE TABLE stusab (...)

This creates a table of state postal codes, one entry per state. It is used by the import scripts to generate a list of files to import.

## Standard Function Parameters

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

## Staging Tables and Data Import Functions.sql

### Functions to Create the Staging Tables

    sql_create_tmp_geoheader([exec boolean])

This script generates the SQL script to create tmp_geoheader. Since the geoheader file is fixed length, tmp_geoheader has a single column.

    sql_import_geoheader([exec boolean[, stusab_criteria text array]])

This script generates the COPY statements which actually import the geoheader files to the staging tables. 

    sql_drop_import_tables([exec boolean])

This drops all staging tables for the estimate sequences and margin of error sequences. If you only want to drop estimates or margin of error staging tables, call, you must generate the script and only run the first or second half (drop estimats and drop MOE tables, respectively).

    sql_create_import_tables([exec boolean])

This creates all staging tables for the estimate sequences and margin of error sequences. If you only want to create staging tables for estimates or for margins of error call, you must generate the script and only run the first or second half (drop estimats and drop MOE tables, respectively). Note that generating the staging tables is harmless. If you don't import margins of error, the margins of error tables won't be used and you can clean up with sql_drop_import_tables() after the estimates data has been moved to it's final destination.

### Functions to Import the Data

The import functions generate COPY statements which do the actual data import to the staging tables created in the previous step. COPY requires that the files be on the server's own filesystem (unlike psql \copy). Since these datasets are large, this is probably a good idea anyway.

    sql_import_geoheader([exec boolean[, stusab_criteria text array]])

Imports the geoheader file for the designated states to tmp_geoheader.

    sql_import_sequences([exec boolean[, stusab_criteria text array[, seq_criteria int array [, actions text]]]])

Imports the sequence files to the estimate staging tables and the margin of error staging tables. The first three parameters are explained above. The actions parameter determines what part of the entire Census dataset to import (or generate scripts for). The parameter is inspected for the letters a, t, e, and m, in any order.

a: Indicates to import the All_Geographies_Not_Tracts_Block_Groups files (large geographies).
t: Indicates to import the Tracts_Block_Groups_Only files (small geographies).
e: Indicates to import the estimates.
m: Indicates to import the margins of error.

Other letters are ignored. As a shortcut, if both large and small geographies are desired, a and t can be omitted. Thus, 'e' is the same as 'ate', and will import estimates only, for both large and small geographies. Similarly, if both estimates and margins of error are desired, e and m can be omitted. Thus, 't' is the same as 'tem', and will import both estimates and margins of error for small geographies only.

## Geoheader.sql

Geoheader will only be populated if the data manager chooses the Table-based Data Store. However, the geoheader table definition is used to create tables for Array and Hstore-based Data Stores, so it should be created in any event.

    sql_create_geoheader([exec boolean])

Creates the geoheader table.

    sql_geoheader_comments([exec boolean])

Adds comments to the geoheader columns (taken from geoheader_schema).

    sql_parse_tmp_geoheader([exec boolean[, target text]])

target: The table to be populated with geoheader data. Defaults to 'geoheader'.

Parses the fixed-length data in tmp_geoheader (based on field definitions in geoheader_schema) and INSERTs the data into a target table. If the data manager uses the table-based data store, the target should be geoheader (the default). If using the array-based or hstore-based data store, sql_parse_tmp_geoheader() should be executed *after* those data stores are created and the table name should be set appropriately (see below, currently these storage structures are experimental and the names are by_array and by_hstore).

## Data Store Table-Based.sql

    sql_store_by_tables([exec boolean])

Creates two database tables for each sequence/segment--one table for estimates, one for margins of error--essentially mirroring the structure in which the data is released. 

    sql_view_estimate_stored_by_tables([exec boolean])

Creates one database view displaying estimates for each "subject table". 

    sql_view_moe_stored_by_tables([exec boolean])

Creates one database view for each "subject table". Margin of error will rarely be used independent of their estimate, the MOE views return estimates as well as margins of error.

    sql_insert_into_tables([exec boolean[, actions text]])

Transfers data from the staging tables to the estimate and margin of error tables. The actions parameter determines what part of the entire Census dataset to move to final storage (or generate scripts for). If omitted, the default is to operate on both the estimates and margins of error. The parameter is inspected for the letters e and m, in any order.

e: Indicates to import the estimates.
m: Indicates to import the margins of error.

Other letters are ignored. An empty string or a string with neither e nor m is treated as a missing parameter, and follows the default behavior which is to operate on both estimates and margins of error.


## Data Store Array-Based.sql

Currently incomplete. Provided for your amusement.

## Data Store Hstore-Based.sql

Currently incomplete. Provided for your amusement.

# Running the Data Functions from Start to Finish

The general procedure is:

1. Run the meta-scripts (previous section). These create functions and support tables. This only needs to be done once, laying the ground for import of multiple Census products.
2. Run set_census_upload_root(). This also only needs to be run once, as long as you download each data product to a subfolder of this root.
3. Create the schema to hold your data (e.g. acs2010_5yr). Change the search_path to that schema.
4. Run the data dictionary functions (next subsection). These functions create tables and views which hold support information relevant to a specific data product, including field names of the geoheader, sequences/segments, and subject tables.
5. Run the data functions. These generate (and optionally execute) the scripts listed in the previous section. They must be run in a specific order.

## The Product-Specific Data Dictionary Script

Each product has a product-specific script which imports the data dictionary and creates some views based on the data dictionary. As an example, look at "ACS 2010 Data Dictionary.sql". This script

1. Creates a schema named acs2010_5yr (uncomment line to execute).
2. Creates a geoheader_schema table. The geoheader changes from year to year, so the schema is a list of field names and start and end positions, allowing the creation of a geoheader table with the appropriate structure and the parsing of the fixed length geoheader files.
3. Creates the data_dictionary table.
4. Imports the data dictionary file from <census_upload_root>/acs2010_5yr.
5. Creates views which extract the sequences, subject tables, and subject table cells from data_dictionary.

## Run the Data Functions

If (a) the meta-scripts have been run, generating all necessary data functions, and (b) the product-specific data dictionary has been imported, then the data functions will actually create (and optionally run) the SQL statements to create the necessary data structures and import the data. They should be run in this order:

```sql
SET search_path = acs2010_5yr, public;
SET client_encoding = 'LATIN1';
SELECT sql_create_tmp_geoheader(TRUE);
SELECT sql_import_geoheader(TRUE); --Imports all states
SELECT sql_create_import_tables(TRUE);
SELECT sql_import_sequences(TRUE); --Imports margins of error and estimates for all states and sequences
SELECT sql_create_geoheader(TRUE);
SELECT sql_geoheader_comments(TRUE);

--For table-based data store:
SELECT sql_store_by_tables(TRUE);
SELECT sql_view_estimate_stored_by_tables(TRUE);
SELECT sql_view_moe_stored_by_tables(TRUE);
SELECT sql_parse_tmp_geoheader(TRUE); --Copies all data from tmp_geoheader to geoheader
SELECT sql_insert_into_tables(TRUE); --Copies all estimates and margins of error to sequence tables
```

If using array-based or hstore-based data store, the last five functions will be different.

Note that the functions sql_import_sequences() and sql_insert_into_tables() will take a LO-O-ONG time to execute, at least overnight, possibly more than one overnight. These can be speeded up by using the parameters to do only states, sequences, or geographies in various batches. As I experiment, I may come up with better faster ways to do this. If you are running Postgres 9.1, you can speed up import by altering sql_create_import_tables() to create UNLOGGED tables (http://www.postgresql.org/docs/9.1/interactive/sql-createtable.html). If you are not using Postgres 9.1, logging can be avoided if the staging table is created or truncated prior to import, and the COPY statements are part of the same transaction, i.e. The functions as currently written do not make this easy to do.

# Future Plans

The array column-based storage method and hstore-based storage method need to be completed. Then I want to test some typical extracts and calculations against the different storage methods, to see which one performs the best.

Partitioning might improve query speed. If partitioned by state, it might ease bulk loading as well. This should be investigated.

The data are most interesting when mapped. These data can be joined with geographic data for this purpose. The population data are released with multiple geographic scales appearing in the same file, but most geographic information systems will separate administrative units hierarchically, i.e. states and counties would not appear in the same GIS layer. A format that separated the data by geography would facilitate geographic visualization. Partitioning by region (e.g. by state), as mentioned in the last paragraph, would undoubtedly speed up visualization.

For comments, or if you are interested in assisting, please feel free to contact me at Lee.Hachadoorian@gmail.com

These scripts are released under the GNU General Public License.

















