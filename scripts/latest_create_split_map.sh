#! /bin/bash
# 
# This is the latest Garmin map creating run for a multi tile img (experimental!)
#
# time env name=Ardeche      top=45.798  left=2.681  bottom=42.440  right=5.076 ./scripts/latest_create_split_map.sh
# time env name=FranceSudEst top=47.887  left=1.582  bottom=40.930  right=8.218 ./scripts/latest_create_split_map.sh

map="/export/data/OSM/france-latest.osm.pbf"
contours="/export/data/OSM/srtm_france_sud_est.osm"

java='/opt/jre1.7.0/bin/java -Xmx2000m -Xms128m -ea '
osmosis="$HOME/Downloads/OSM/bin/osmosis"
mkgmap="$java -jar /home/wrk/Downloads/OSM/mkgmap-r3294/mkgmap.jar"
splitter="$java -jar $HOME/Downloads/OSM/splitter-r411/splitter.jar"
phyghtmap=/usr/bin/phyghtmap

if [ ! -d hiking_styles ]; then
  echo "Not in OSM generator dir, see https://github.com/pjotrp/OSM"
  exit 1
fi

if [ ! -e map.osm ]; then
  echo "Checking map area for $name:"
  ruby -e "p (($top-$bottom)*($left-$right)).abs"

  echo "Clean up"
  rm -v *.img *.tdb *.mdx *.pbf lon* areas.* *.args densities*
  rm -rvf ~/.config/QLandkarteGT/

  echo "Reduce the main OSM map to map.osm..."
  $osmosis --read-pbf file=$map --bounding-box top=$top left=$left bottom=$bottom right=$right --write-xml "map.osm"
  [ $? -ne 0 ] && exit 1
fi

ls -lh *.osm

if [ ! -e 63240001.osm.pbf ]; then
  $splitter map.osm
  [ $? -ne 0 ] && exit 1
fi

if [ ! -e contours.osm ]; then
  echo "Reduce the contours OSM map to contours.osm..."
  $osmosis --read-xml file=$contours --bounding-box top=$top left=$left bottom=$bottom right=$right --write-xml "contours.osm"
  [ $? -ne 0 ] && exit 1
fi

# Osmosis has a bug here (fixed in trunk, but not released)
#
# At the moment osmosis complains:
#
# SEVERE: Thread for task 1-read-xml failed
# org.openstreetmap.osmosis.core.OsmosisRuntimeException: Cannot represent 68003 as a char.
# 
# $osmosis --read-xml file=contours.osm --sort --write-xml countours_sorted.osm
# $splitter --split-file=areas.list --mixed contours_sorted.osm
#
# So we use phyghtmap instead.

if [ ! -e lon2.68_3.00lat42.44_43.00_srtm3.osm ]; then
  $phyghtmap -0 --step=50 -a $left:$bottom:$right:$top 
  [ $? -ne 0 ] && exit 1
fi

echo "Combine the two maps map.osm and contours.osm..."
time $mkgmap --max-jobs=3 --gmapsupp --style-file=hiking_styles \
  --add-pois-to-areas  --overview-mapname="$name"_bnl --family-id=10010 \
  --product-id=1 --family-name=$name --index --draw-priority=28 \
  -c template.args 10010.TYP --family-id=10011 --product-id=1 \
  --family-name="$name"contours --draw-priority=30 --transparent \
  lon*.osm 10011.TYP --tdbfile
[ $? -ne 0 ] && exit 1

ls -lh gmap*img
cp gmapsupp.img gmapsupp-$name-$top-$left-$bottom-$right.img
