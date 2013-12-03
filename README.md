# Overview

This project consists of a number of SQL scripts and other supporting files for importing recent American Community Survey releases from the US Census Bureau datasets. (Support for importing the Decennial Census will hopefully be added soon.) In order to avoid having to produce copious amounts of documentation, the naming conventions employed adhere very closely to the Census data dictionary. This means that fields are named, e.g., `b07401037` rather than `moved_within_same_county_aged_20_to_24`. The data manager who wants more memorable names is advised to create views aliasing commonly used columns. The data are also maintained in tables named "sequences" so as to make it easy for data managers to drop or load data in the same structures the Census uses for distribution. 

There are two types of scripts:

1. Scripts which create the necessary data schema, bulk load the data to import tables, and coerce it to final form;
2. Meta-scripts, scripts which create functions which generate the schema creation and data import scripts.

The data manager has the choice of running the data import scripts directly, or of running the meta-scripts. The data import scripts are created programmatically by the meta-scripts. The meta-scrips can be run to (a) return the desired SQL statements to inspect or to execute later, or (b) to execute the SQL directly, actually creating multiple tables or views, and loading and transforming the desired data. The first option (running scripts specific to each Census product) is probably conceptually easier to understand. The second option is more powerful, as it gives the data manager more control over the import process, and in practice will be easier to implement once you understand what the scripts are doing.

The data definition and data manipulation scripts appear in the folders named for specific Census products (e.g. 2010_5yr). The meta-scripts appear in the meta-scripts folder. My desire is to eventually make the schema creation and data import scripts (the first kind of script) conform to the SQL standard, so that they could be used in other SQL implementations than Postgres. As the meta-scripts (the second kind of script) rely upon PL/pgSQL, I doubt they could be converted to implementation-agnostic. I would be more likely to rewrite them in Python or another language.

There are two ways in which I depart from the Census data formats. I have created the `sumlevel` field as an integer, even though text is arguably more appropriate (the summary level is a three digit field that is often written with prepended zeroes). I have also added the `geoid` field, already present in the `geoheader` table, to the sequence tables as well. Primarily intended by the Census for spatial data support, this field allows a single-key join between `geoheader` and a sequence tables (otherwise the join requires both the state code and an integer identifier that is only unique within states).

A number of optional features are described at the end of this file.

# Getting the Data

Various Census data products are available via HTTP at www2.census.gov or via anonymous FTP at ftp2.census.gov. An FTP client will make it easy to download large numbers of files or entire folders. Using HTTP can be tedious unless, instead of a web browser, you use a helper program such as wget. For example:

```
wget --recursive --no-parent --accept zip "http://www2.census.gov/acs2010_5yr/summaryfile/2006-2010_ACSSF_By_State_All_Tables/"
```

will fetch all files associated with the ACS 2010 5-year product. Note that with ACS 2011, the Census Bureau has made it easier to download the entire data product in two giant TAR files. They previously made it available as two giant ZIP files, but I always had trouble getting those to unzip successfully.

Each data product (e.g. American Community Survey 2006-2010) can be thought of as one large file, but the data are horizontally partitioned by state and are vertically separated into "segments" (in the Decennial Census) or "sequences" (in ACS) of less than 256 columns each. This makes for an extremely large number of tables that have to be bulk loaded. These import routines assume that all Decennial Census files will be staged in a single directory. The ACS data are separated into large and small geographies, *but file names are reused for both the large and the small geographies*. In order to distinguish between them, the import routines assume that the two types of files are separated into a directories named All_Geographies_Not_Tracts_Block_Groups and Tracts_Block_Groups_Only. In each case, the parent directory name must match the name of the database schema where the data will be stored. I name the schemas after the datasets folder name on the Census Bureau FTP server, e.g. acs2010_5yr.

# Running the Data Scripts

**The following instructions indicate how to import the Census data using the data import scripts. If you would prefer to use the meta-scripts, you do not need to read this. Instead, look at the README in the meta-scripts folder.**

The data scripts should be run in a specific order. They will generate storage tables, staging (temp) tables, and views which mirror Census "subject tables", as well as actually doing the data import.

*Table and view names in these scripts are* ***not*** *schema-qualified,* allowing the data manager to choose their own schema name. As mentioned above, I use a schema name based on folder names from the Census Bureau FTP server. Assuming you do the same, each script needs to prepended with 

```sql
SET search_path = acs2010_5yr, public; --or other appropriate schema name
```

If you want to avoid altering each script, SET search_path once in psql, then \i each script file.

## Create Staging Tables

DROP and CREATE TABLE scripts are separated so that half-loaded datasets won't accidentally be deleted, and so that data can be loaded in batches. Work process might be to import an entire state or group of states into the staging tables, push data into final storage tables, then drop all the staging tables. When importing another batch, recreate the staging tables.

These scripts may be run in any order.

* create_tmp_geoheader.sql (contains `DROP … IF EXISTS` statement)
* drop_import_tables.sql
* create_import_tables.sql
* drop_import_moe.sql
* create_import_moe.sql

## Import Data

These scripts use COPY statements to do the actual data import, albeit to staging tables, not to the final destination. COPY requires that the files be on the server's own filesystem (unlike psql \copy). Since these datasets are large, this is probably a good idea anyway.

These scripts use forward slashes to represent filesystem separators. Testing on Windows Vista indicates that forward slashes will be interpreted correctly. Backslashes, if used, are treated as escape characters and would need to be doubled.

These scripts contain a filesystem placeholder "\<census_upload_root\>". This placeholder should be updated to reflect your filesystem. This folder should have a child matching the Census product name, e.g. `acs2010_5yr`. The `acs2010_5yr` folder should have two children. As mentioned above, the files downloaded from Census should be in two sibling directories named `All_Geographies_Not_Tracts_Block_Groups` and `Tracts_Block_Groups_Only`. 

The geoheader files use a fixed-length format, and are therefore imported to a table with a single column. This column is then parsed for insertion into the final `geoheader` table. The geoheader files contain *all* geographies, in spite of whether they are downloaded with the larger or smaller (tracts and block groups only) datasets. These scripts assume the existence of the `All_Geographies_Not_Tracts_Block_Groups` folder. If you have only downloaded the tracts and block groups, you will have to modify the script or create the expected folder and move the geography files (`g20105xx.txt`).

These scripts may be run in any order.

* import_geoheader.sql
* import_sequences.sql

## Create Data Store

Researchers will typically interact with the data via a "subject table" a collection of related data. Often a subject table will break down the population into categories (e.g. age and sex) and include summary columns (e.g. total population, male population, female population). The data are stored by sequences, so subject tables are constructed as views.

### Create Geoheader

The `geoheader` table is the glue that holds the ACS together. It contains names of the geographic units (e.g. state or county names), as well as the unit's path in the Census geographic hierarchy (e.g. State → County → Census Tract).

* create_geoheader.sql

After running, `tmp_geoheader` may be TRUNCATEd or DROPped, so that when additional data is imported, parse_tmp_geoheader.sql does not attempt to create duplicate records (which will fail due to PRIMARY KEY violation).

### Create Table-based Data Store

These scripts create two tables for each sequence, one with estimates (named `seqnnnn`), and one with margins of error (named `seqnnnn_moe`). Column names are unique (margin of error tables have `_moe` at the end of column names) except for key fields so that the tables can be joined without conflict or confusion. These scripts must be run in this order.

Parse_tmp_geoheader.sql may be run at any time. The other scripts must be run in order.

* parse_tmp_geoheader.sql
1. store_by_tables.sql
2. store_moe_by_tables.sql
3. insert_into_tables.sql
4. insert_into_moe.sql
5. view_estimate_stored_by_tables.sql
6. view_moe_stored_by_tables.sql

# Optional Features

The following features are not necessary to the project, but may be of interest to some data managers.

## PostGIS Support

Demographic data is inherently spatial, and many ACS data users will want to map the data. If you have installed the PostGIS extension, you may be interested in the scripts included in the `postgis_support` folder. The modifications are minor, but useful. Basically, a geometry column and a unique integer identifier are added to the `geoheader` table. Spatial data from any source may be copied to the file, but I assume use of TIGER/Line data from USCB. If you use data from a different source, the SRID of the geometry column (4269 for USCB sources) may need to be changed.

Note that the standard Geographic Information System paradigm is to view a spatial "layer" as a collection of entities at the same scale (e.g., only counties), while the ACS mashes all geographies, from the nation down to block groups, into one table, with a `sumlevel` ("summary level") column to separate them out. Since most GISes will not expect to work with data organized this way, the data manager intending to support spatial analysis might also want to implement partitioning (next section).

## Partitioning

**Currently under development**

It is expected that analysts will usually be working with data within a geographic scale (e.g. running a regression on county-level data), and often working within a defined region. Scale is identified by two columns, `sumlevel` and `component`, where `sumlevel` represents the level in the geographic hierarchy from Nation to State to County, etc. (and many others such as Tribal Tracts, ZIP Code Tabulation Areas or ZCTAs, Metropolitan and Micropolitan Areas, etc.) and `component` represents a subset of the population in that geography, e.g. Urban only or Rural only population. (The code `00` represents total population, and is often the component of interest. Codes other than `00` are only defined for county and geographies and larger.)

Rather than require the analyst to constantly filter based on scale, the data may be partitioned by summary level and component. Since I anticipate that the analyst will rarely require data from multiple scales in the same query (and when desired this can easily be accomplished by a UNION query), and in order to avoid GIS users adding a layer with states, counties, tracts, ZCTAs, etc. all layered on top of each other, this is *not* implemented using inheritance. Partitioning this way will also save storage space, as many sequences contain *no* data for specific summary levels, but rows representing those geographies nonetheless appear in the sequence files with all NULLs after the identifying columns. Therefore when creating these partitions, the script will check for all NULL rows and not add those rows to the partition.

The tables may be partitioned at a variety of geographic scales, but since the data are distributed by state, partitioning is implemented by state. This is standard partitioning (i.e. *with* inheritance), since the analyst might at different points want to query a specific state or all states in the country. This will also aid use in GIS, as the analyst can easily add one state or a handful of neighboring states by table, or add the entire country or construct a more complex geographic query (e.g., by metropolitan area) that crosses state boundaries. 

## Alternative Storage Formats

I am experimenting with two alternative storage formats which combine all the sequences into one table. Because of Postgres' limit of ~2000 columns in a table, to combine all the data into one table I use array columns (one per sequence) or one hstore column to store the data. In testing, the array column approach breaks down as the row size gets past 20 or so sequences (even with toast tables helping out), and the hstore approach was *extremely* slow for data loading. Experiment at your own risk, and let me know what you discover.

If following the one-big-table approach, the geoheader columns appear as the first columns in these tables (either array column or hstore). Nonetheless, the CREATE TABLE scripts rely upon the existence of `geoheader` (using the LIKE keyword), so `create_geoheader.sql` should be run in any event.

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

The array column-based storage method and hstore-based storage methods are half-baked, but so far don't seem promising. I still want to test some typical extracts and calculations against the different storage methods, to see which one performs the best.

Partitioning is currently being implemented.

The data are most interesting when mapped. The basic requirements of PostGIS support have been added. A useful feature would be to completely automate downloading the spatial data from the Census, loading it into Postgres, and joining it permanently to the demographic data.

For comments, or if you are interested in assisting, please feel free to contact me at Lee.Hachadoorian@gmail.com

These scripts are released under the GNU General Public License.

















