#!/bin/bash

# Script to wget Census TIGER/Line water shapefiles and import them into PostGIS.
# Assumes existence of geo_water schema. Assumes target table must be created.
# Script would have to be modified if you have previously done a partial import
# and want to append to an existing table.
#
# Could be adapted to other features (states, roads, etc.). Not all geographies
# are available for all features. Availability also varies across vintage.
#	* states may be available in one US file or by state
#	* counties may be available in one US file or by state
#	* places are only available by state
#	* tracts may be available by state or by county
#	* areawater is only available by county
# File search patterns:
# 	*_us_*.zip will download US file
#	*_<nn>_*.zip will download a specific state, nn
#	*_##_*.zip will download all state files
#	*_<nnnnn>_*.zip will download a specific county, nnnnn
#	*_<nn>###_*.zip will download all counties in a specific state, nn
#	*_#####_*.zip will download all county files

DBNAME=$1
USERNAME=$2

wget -r -np -nH --cut-dirs=2 -A zip ftp://ftp2.census.gov/geo/tiger/TIGER2010/AREAWATER/

cd TIGER2010/AREAWATER
unzip \*.zip
rm *.zip

FILES=$(find -name "*.shp");
BINHERE=0
for FILE in $FILES
do
  BASE=$(basename $FILE .shp)
  if [ $BINHERE -eq 0 ] ; then

    echo "Creating table, appending ${BASE}"
    shp2pgsql -s 4269 -c -I -g geom -W LATIN1 $BASE geo_water.tiger_areawater_2010 | psql $DBNAME -U $USERNAME
    BINHERE=1
  else
    echo "Appending ${BASE}"
    shp2pgsql -s 4269 -a -g geom -W LATIN1 $BASE geo_water.tiger_areawater_2010 | psql $DBNAME -U $USERNAME
  fi
done


