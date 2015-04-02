# !/bin/sh
# 

project_dir="/Users/granthumphries/Coding/git/sw-trails-web-map"

# bounding box should be feed to overpass in the following order
# min lat, min lon, max lat, max lon (or S-W-N-E)

min_lat="45.433144"
min_lon="-122.763594"
max_lat="45.5177"
max_lon="-122.639207"

getOsmJsonFromOverpass() {
	osm_geojson="${project_dir}/test.geojson"

	overpass_url="http://overpass-api.de/api/interpreter?data="
	tags="[highway=\"footway\"]"
	bbox="(${min_lat}, ${min_lon}, ${max_lat}, ${max_lon})"

	echo "wget -O $osm_geojson ${overpass_url}${format};way${tags}${bbox};out body;>;out skel qt;"
	wget -O $osm_geojson "${overpass_url};way${tags}${bbox};out body;>;out skel qt;"
}

#getOsmJsonFromOverpass;

wget -O "new_test.geojson" "http://overpass-api.de/api/interpreter?data=[out:json][timeout:25];(way[\"highway\"=\"footway\"](45.49208889579099,-122.70986080169678,45.50326398859537,-122.69288778305055););out body;>;out skel qt;"

# WHAT TO DO NEXT
# geojson is different than json, so first .osm must be downloaded from overpass
# https://help.openstreetmap.org/questions/24126/overpassapi-different-json-formats

# then the convert osm must be converted to geojson
# http://gis.stackexchange.com/questions/22788/how-do-you-convert-osm-xml-to-geojson