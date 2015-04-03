# !/bin/sh

# get OSM trail data from the overpass api as .osm and convert it to geojson
# using ogr2ogr

project_dir="/Users/granthumphries/Coding/git/sw-trails-web-map"

# bounding box should be feed to overpass in the following order
# min-lat,min-lon,max-lat,max-lon (or S,W,N,E)

min_lat="45.433144"
min_lon="-122.763594"
max_lat="45.5177"
max_lon="-122.639207"

osm_file="${project_dir}/data/sw_trails.osm"
geojson_file="${project_dir}/data/sw_trails.geojson"

getOsmJsonFromOverpass() {
	overpass_url="http://overpass-api.de/api/interpreter?data="
	tags="[highway~\"footway|path|cycleway|pedestrian|steps\"]"
	bbox="(${min_lat}, ${min_lon}, ${max_lat}, ${max_lon})"

	# docs on overpass query language here:
	# http://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL
	# the phrase '(._;>;)' takes the result of the first part pf the query, the
	# way with out its nodes, recurses down and gets the nodes that belong to the
	# way and then unions them (that's what the parens do)
	echo "wget -O $osm_file ${overpass_url}way${tags}${bbox};(._;>;);out body;"
	wget -O $osm_file "${overpass_url}way${tags}${bbox};(._;>;);out body;"
}

osmToGeojson() {
	# delete the geojson file if it already exists
	echo "m -f $geojson_file"
	rm -f $geojson_file

	echo "ogr2ogr -f GeoJSON $geojson_file $osm_file lines"
	ogr2ogr -f GeoJSON $geojson_file $osm_file lines
}

getOsmJsonFromOverpass;
osmToGeojson;