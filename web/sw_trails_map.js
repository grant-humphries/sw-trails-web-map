// extent of sw trails area
var min_lat = 45.433144
var min_lon = -122.763594
var max_lat = 45.5177
var max_lon = -122.639207

// initialize the map object
var map = L.map('map', {
	center: [(min_lat + max_lat)/2, (min_lon + max_lon)/2],
	zoom: 13,
	minZoom: 13,
	// limit the bounds of the map such that one can't exit the SW Trails Area
	maxBounds: new L.latLngBounds([max_lat, min_lon], [min_lat, max_lon])
});


// add base maps
// stamen terrain is added to map as default base layer
var stamen_terrain = L.tileLayer('http://{s}.tile.stamen.com/terrain/{z}/{x}/{y}.jpg', {
	attribution: 'Map tiles by Stamen Design, under CC BY 3.0. Data (c) OpenStreetMap contributors',
	maxZoom: 18
}).addTo(map);

var hnb_base = L.tileLayer('http://toolserver.org/tiles/hikebike/{z}/{x}/{y}.png', {
	attribution: 'Map tiles by Colin Marquardt.  Data (c) OpenStreetMap contributors',
	maxZoom: 17
});

var hnb_hillshade = L.tileLayer('http://toolserver.org/~cmarqu/hill/{z}/{x}/{y}.png', {
	maxZoom: 16
});

// put two hike and bike layers into a single layer group
var hike_and_bike = L.layerGroup([hnb_base, hnb_hillshade]);

var open_cycle_map = L.tileLayer('http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png', {
	attribution: 'Data (c) OpenStreetMap contributors. Tiles courtesy of Andy Allan',
	maxZoom: 18
});

var baseMaps = {
	'Stamen Terrain': stamen_terrain,
	'Hike & Bike Map': hike_and_bike,
	'Open Cycle Map': open_cycle_map,
	'No Base Map': L.tileLayer('')
};

// add layer control
L.control.layers(baseMaps).addTo(map);


var test_style = {
	color: 'green',
	weight: 2,
	opacity: 0.5,
	dashArray: '5, 5'
};

// add geojson trails
$.getJSON('sw_trails.geojson', function(data) {
	L.geoJson(data, {
		style: test_style
	}).addTo(map);
});

// add cutout bounding box displaying the extent of the SW Trails PDX area
var b_box_polygon = L.polygon([
	// outer ring (covers planet)
	[[90, -180], [90, 180], [-90, 180], [-90, -180]], [
	// inner ring (sw trails area)
	[max_lat, min_lon],	[max_lat, max_lon],
	[min_lat, max_lon], [min_lat, min_lon]]], {
	// polygon style
	color: 'white',
	opacity: 0.9,
	fillColor: 'white',
	fillOpacity: 0.8}
).addTo(map);
