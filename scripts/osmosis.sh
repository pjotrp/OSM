# Reduce map and contours using coordinates
#
# Run as: . ./OSM/scripts/osmosis.sh ../france-latest.osm.pbf ../srtm-france-sud-est.osm

map=$1
contours=$2

echo Files: $map $contours
echo Coordinates: $left,$top $right,$bottom

osmosis --read-pbf file=$map --bounding-box top=$top left=$left bottom=$bottom right=$right --write-xml map.osm

osmosis --read-xml file=$contours --bounding-box top=$top left=$left bottom=$bottom right=$right --write-xml contours.osm
