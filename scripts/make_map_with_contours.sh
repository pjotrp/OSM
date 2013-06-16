#! /bin/sh
#
# Run this script from the directory containing your OSM files.
#
# See also http://thebird.nl/tutorials/osm_garmin.html

map=$1
contours=$2

if [ -z $map ]; then map=map.osm ; fi
if [ -z $contours ]; then contours=contours.osm ; fi

if [ ! -f $map ] ; then echo missing $map ; exit 1 ; fi
if [ ! -f $contours ] ; then echo missing $contours ; exit 1 ; fi
rm -rvf ~/.config/QLandkarteGT/

rm -v *.img *.mdx *.tdb
ls -lh
mkgmap="java -Xmx4024m -Xms128m -ea -jar $HOME/opt/mkgmap-r2643/mkgmap.jar"

$mkgmap --tdbfile --gmapsupp --index \
  --remove-short-arcs \
  --style-file=OSM/hiking_styles --add-pois-to-areas \
  --overview-mapname=ofm_bnl --family-id=10010 \
  --product-id=1 --family-name=cycle \
  --draw-priority=25 $map OSM/10010.TYP \
  --family-id=10011 \
  --product-id=1 --family-name=contours --draw-priority=30 \
  --transparent $contours OSM/10011.TYP

