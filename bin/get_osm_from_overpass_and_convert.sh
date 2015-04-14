# !/bin/sh

# get OSM trail data from the overpass api as .osm and convert it to geojson
# using ogr2ogr

data_dir='/Users/granthumphries/Coding/git/sw-trails-web-map/data'
mkdir -p $data_dir

getOsmFileFromOverpass() {
	min_lat="$1"
	min_lon="$2"
	max_lat="$3"
	max_lon="$4"
	osm_file="$5"

	# bounding box should be feed to overpass in the following order
	# min-lat,min-lon,max-lat,max-lon (or S,W,N,E)
	bbox="(${min_lat}, ${min_lon}, ${max_lat}, ${max_lon})"

	overpass_url="http://overpass-api.de/api/interpreter?data="
	tag1="[highway~\"footway|path|cycleway|bridleway|pedestrian|steps\"]"
	tag2="[footway!=\"sidewalk\"]"
	
	# docs on overpass query language here:
	# http://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL
	# the phrase '(._;>;)' takes the result of the first part pf the query, the
	# way with out its nodes, recurses down and gets the nodes that belong to the
	# way and then unions them (that's what the parens do)
	echo "${overpass_url}way${tag1}${tag2}${bbox};(._;>;);out body;"
	wget -O $osm_file "${overpass_url}way${tag1}${tag2}${bbox};(._;>;);out body;"
}

osmToOgr() {
	out_format="$1"
	out_file="$2"
	osm_file="$3"


	# delete output file if it exists from previous conversion
	echo "rm -rf $out_file"
	rm -rf "$out_file"

	echo "ogr2ogr -f $out_format $out_file $osm_file lines"
	ogr2ogr -f "$out_format" $out_file $osm_file lines
}

convertCoords() {
	x="$1"
	y="$2"
	in_epsg="$3"
	out_epsg="$4"

	echo "$x" "$y" | gdaltransform -s_srs "EPSG:$in_epsg" -t_srs "EPSG:$out_epsg" 
}


# *** Get sw trails geojson extract from OSM ***
sw_lat1='45.433144'
sw_lon1='-122.763594'
sw_lat2='45.5177'
sw_lon2='-122.639207'

sw_out_format='GeoJSON'
sw_trails_osm="${data_dir}/sw_trails.osm"
sw_trails_geojson="${data_dir}/sw_trails.geojson"

getOsmFileFromOverpass $sw_lat1 $sw_lon1 $sw_lat2 $sw_lon2 $sw_trails_osm;
osmToOgr "$sw_out_format" $sw_trails_geojson $sw_trails_osm;


# *** Convert powell division corridor b-box from oregon state plane north 
# to latitude-longitude coordinates ***
ospn='2913'
wgs84='4326'

pd_x1='7634741.82'
pd_y1='669018.45'
pd_x2='7722347.35'
pd_y2='691403.32'

pd_btm_l_raw=$(convertCoords $pd_x1 $pd_y1 $ospn $wgs84)
pd_btm_l_array=($pd_btm_l_raw)
pd_upr_r_raw=$(convertCoords $pd_x2 $pd_y2 $ospn $wgs84)
pd_upr_r_array=($pd_upr_r_raw)

# get trails for Powell-Division Corridor in shapefile from OSM
pd_lat1="${pd_btm_l_array[1]}"
pd_lon1="${pd_btm_l_array[0]}"
pd_lat2="${pd_upr_r_array[1]}"
pd_lon2="${pd_upr_r_array[0]}"

pd_out_format='ESRI Shapefile'
pd_trails_osm="${data_dir}/pd_corridor_trails.osm"
pd_trails_shp="${data_dir}/shp_pd_corridor_trails.shp"

getOsmFileFromOverpass $pd_lat1 $pd_lon1 $pd_lat2 $pd_lon2 $pd_trails_osm;
osmToOgr "$pd_out_format" $pd_trails_shp $pd_trails_osm;
