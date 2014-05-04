function initialize() {
  var mapOptions = {
    center: new google.maps.LatLng(40.559557, -74.494910),
    zoom: 8
  };
  var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
  var markers = {};

  refreshTrains = function(iteration) {
    $.get('/trains', {}, function(data, textStatus, jqXHR) {
      $.each(data.data, function() {
        var latLng = new google.maps.LatLng(this.lat, this.lon);
        if (markers.hasOwnProperty(this.trip_id)) {
          var marker = markers[this.trip_id];
          marker.setPosition(latLng);
          marker.iteration = iteration;
        } else {
          var marker = new google.maps.Marker({
            position: latLng,
            map: map,
            title: this.trip_name
          });
          marker.iteration = iteration;
          markers[this.trip_id] = marker;
        }
      });

      $.each(markers, function(marker, trip_id) {
        if (marker.iteration < iteration) {
          marker.setMap(null);
          delete markers[trip_id];
        }
      });

      refreshTrains(iteration + 1);
    });
  }
  refreshTrains(1);
}
google.maps.event.addDomListener(window, 'load', initialize);
