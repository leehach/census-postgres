# Overview

This project consists of a number of SQL scripts and other supporting files for importing some recent US Census datasets into a PostgreSQL database. The datasets of interest are the Decennial Census and the annual American Community Survey (ACS). There are two types of scripts:

1. Scripts which create the necessary data schema, bulk load the data to import tables, and coerce it to final form;
2. Meta-scripts, scripts which create functions which generate the schema creation and data import scripts.

My desire is to eventually make the schema creation and data import scripts (the first kind of script) conform to the SQL standard, so that they could be used in other SQL implementations than Postgres. As the meta-scripts (the second kind of script) rely upon PL/pgSQL, I doubt they could be converted to implementation-agnostic. I would be more likely to rewrite them in Python or another language.

# Getting the Data

Instructions for obtaining the data via FTP to appear here.

Each data product (e.g. American Community Survey 2006-2010) can be thought of as one large file, but the data are horizontally partitioned by state and are vertically separated into "segments" (in the Decennial Census) or "sequences" (in ACS) of less than 256 columns each. This makes for an extremely large number of tables that have to be bulk loaded. These import routines assume that all Decennial Census files will be staged in a single directory. The ACS data are separated into large and small geographies, *but file names are reused for both the large and the small geographies*. In order to distinguish between them, the import routines assume that the two types of files are separated into a directories named All_Geographies_Not_Tracts_Block_Groups and Tracts_Block_Groups_0nly. In each case, the parent directory name must match the name of the database schema where the data will be stored. I name the schemas after the datasets folder name on the Census Bureau FTP server, e.g. acs2010_5yr.

# Running the Data Scripts

The data scripts should be run in a specific order. They will generate storage tables, staging (temp) tables, and views which mirror Census "subject tables", as well as actually doing the data import.

*Table and view names in these scripts are ***not*** schema-qualified,* allowing the data manager to choose their own schema name. As mentioned above, I use a schema name based on folder names from the Census Bureau FTP server. Assuming you do the same, each script needs to prepended with 

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

These scripts contain a filesystem placeholder "<census_upload_root>". This placeholder should be updated to reflect your filesystem. This folder should have a child named acs2010_5yr. The acs2010_5yr folder should have two children. As mentioned above, the files downloaded from Census should be in two sibling directories named All_Geographies_Not_Tracts_Block_Groups and Tracts_Block_Groups_0nly. 

The geoheader files use a fixed-length format, and are therefore imported to a table with a single column. This column is then parsed for insertion the the final geoheader table. The geoheader files contain *all* geographies, in spite of whether they are downloaded with the larger or smaller (tracts and block groups only) datasets. These scripts assume the existence of the All_Geographies_Not_Tracts_Block_Groups folder. If you have only downloaded the tracts and block groups, you will have to modify the script or create the expected folder and move the geography files (g20105xx.txt).

Meta-scripts (to be released later) will make it easier to import selected states or sequences. For now, the data manager will have to manually select the states and sequences desired from these files.

These scripts may be run in any order.

* import_geoheader.sql
* import_sequences.sql

## Create Data Store

At the moment I am experimenting with three different storage formats. The only one that is completed stores each sequence in its own database table. The other two options combine all the sequences into one table, but, because of Postgres' limit of ~2000 columns in a table, use array columns (one per sequence) or one hstore column to store the data. For information on the status of these options, see below.

Researchers will typically interact with the data via a "subject table" a collection of related data. Often a suject table will break down the population into categories (e.g. age and sex) and include summary columns (e.g. total population, male population, female population). The data are stored by sequences (except for hstore, which pushes the entire dataset into two columns), so subject tables are constructed as views. The view definitions will of course depend upon which data storage method is chosen. **Currently, views are only defined for the table-based data store.**

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
5. view_subject_stored_by_tables.sql
6. view_subject_moe_stored_by_tables.sql

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

# Future Plans

These scripts were created with meta-scripts. As soon as the meta-scripts are inspected, they will be posted as well. This will allow the import of other Census Bureau datasets.

The array column-based storage method and hstore-based storage method need to be completed. Then I want to test some typical extracts and calculations against the different storage methods, to see which one performs the best.

Partitioning might improve query speed. If partitioned by state, it might ease bulk loading as well. This should be investigated.

The data are most interested when mapped. These data can be joined with geographic data for this purpose. The population data are released with multiple geographic scales appearing in the same file, but most geographic information systems will separate administrative units hierarchically, i.e. states and counties would not appear in the same GIS layer. A format that separated the  data by geography would facilitate geographic visualization. Partitioning by region (e.g. by state), as mentioned in the last paragraph, would undoubtedly speed up visualization.

For comments, or if you are interested in assisting, please feel free to contact me at Lee.Hachadoorian@gmail.com

These scripts are released under the GNU General Public License.

















