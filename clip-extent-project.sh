# this script clips all data in a directory to a bounding box coordinates, projects clipped data to a desired SRS,
# moves processed data to a new location, and removes unprojected clipped data.
# I find this useful for cartography when working with Natural Earth Data, see http://www.naturalearthdata.com/
# *************************************************************

# step 1: clip all shapefiles to specified lat lon bounding coordinates (x min y min x max y max)
# note: data must be in WGS84, if in a different projection use that SRS' coordinate values 
# *************************************************************

# set variables for bounding box coordinates here
# minimum latitude  (min y value)
LAT_MIN=8
# minimum longitude ( min x value)
LON_MIN=-24.7
# maximum latitude  (max y value)
LAT_MAX=49.2
# maximum longitdue (max x value)
LON_MAX=66.3

# set variables for -s_srs and -t_srs here
S_SRS='EPSG:4326'    #data's source coordinate system / projection
T_SRS='EPSG:3395'    #data's target coordinate system / projection

# set path for output .shp files here
DIR_OUT=/Users/chrishenrick/temp/test

# variable values for sed here:
PRJ=`echo $T_SRS | sed s/\"//g | cut -f2 -d ':'`

for FILE in *.shp
do
 echo "Clipping $FILE file..."
 FILENEW=`echo $FILE | sed "s/.shp/_clip.shp/"`
 ogr2ogr \
 -clipsrc $LON_MIN $LAT_MIN $LON_MAX $LAT_MAX \
 $FILENEW  $FILE

done

# step2: project all clipped data to a desired SRS such as EPSG:26904
# *************************************************************
# frequently used projections:
# 3395 wgs84 world mercator
# 900913 google web-mercator
# 3857 pseudo mercator (depreciated)

# project all clipped data to a desired SRS such as EPSG:3395 WGS84 World Mercator
for FILE in *_clip.shp
do
 echo "Projecting $FILE file..."
 FILENEW=`echo $FILE | sed "s/.shp/_$PRJ.shp/"`
 ogr2ogr \
 -s_srs $S_SRS -t_srs $T_SRS \
 $FILENEW  $FILE\

done

# step3: move all clipped and projected files to the project folder.
# *************************************************************

for FILE in *_$PRJ.*
do
 echo "moving $FILE file..."
 mv $FILE $DIR_OUT

done

# step 4: clean up. delete all clipped, unprojected files still in WGS84 (original coordinate system) that won't be needed.
# *************************************************************

for FILE in *_clip.*
do
 echo "deleting $FILE file..."
 rm $FILE
 
done