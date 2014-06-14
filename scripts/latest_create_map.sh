#! /bin/bash
# 
# This is the latest Garmin map creating run for a single tile.
#
# env name=test top=44.1408 left=3.3192 bottom=43.6937 right=4.0814 ./scripts/latest_create_map.sh
#
# Other used coordinates are
#
# Montpellier, Sete, Ganges  name=Montpellier top=44.0    left=3.3948 bottom=43.3452 right=4.0869
# Geneva                     name=Geneva      top=46.898  left=5.251  bottom=45.959  right=6.372
# Aubenas                    name=Aubenas     top=44.903  left=3.873  bottom=44.222  right=4.768
#
# time env name=Ganges      top=44.1408 left=3.3192 bottom=43.6937 right=4.0814 ./scripts/latest_create_map.sh
# time env name=Aubenas     top=44.903  left=3.873  bottom=44.222  right=4.768  ./scripts/latest_create_map.sh
# time env name=Montpellier top=44.0    left=3.3948 bottom=43.3452 right=4.0869 ./scripts/latest_create_map.sh

map="/export/data/OSM/france-latest.osm.pbf"
contours="/export/data/OSM/srtm_france_sud_est.osm"

osmosis="$HOME/Downloads/OSM/osmosis/bin/osmosis"
mkgmap='/opt/jre1.7.0/bin/java -jar /home/wrk/Downloads/OSM/mkgmap-r3294/mkgmap.jar'

if [ ! -d hiking_styles ]; then
  echo "Not in OSM generator dir, see https://github.com/pjotrp/OSM"
  exit 1
fi

echo "Checking map area for $name:"
ruby -e "p (($top-$bottom)*($left-$right)).abs"

echo "Clean up"
rm -v *.img 
rm -rvf ~/.config/QLandkarteGT/

echo "Reduce the main OSM map to map.osm..."
$osmosis --read-pbf file=$map --bounding-box top=$top left=$left bottom=$bottom right=$right --write-xml "map.osm"
[ $? -ne 0 ] && exit 1
ls -lh map.osm

echo "Reduce the contours OSM map to contours.osm..."
$osmosis --read-xml file=$contours --bounding-box top=$top left=$left bottom=$bottom right=$right --write-xml "contours.osm"
[ $? -ne 0 ] && exit 1

echo "Combine the two maps map.osm and contours.osm..."
time $mkgmap --max-jobs=3 --gmapsupp --style-file=hiking_styles \
  --add-pois-to-areas  --overview-mapname="$name"_bnl --family-id=10010 \
  --product-id=1 --family-name=$name --index --draw-priority=28 \
  map.osm 10010.TYP --family-id=10011 --product-id=1 \
  --family-name="$name"contours --draw-priority=30 --transparent \
  contours.osm 10011.TYP --tdbfile

ls -lh gmap*img
cp gmapsupp.img gmapsupp-$name-$top-$left-$bottom-$right.img
