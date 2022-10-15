import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    markers: Array,
    center: Array,
    radius: Number
  }

  static targets = [ 'map' ]

  connect() {
    console.log("Openstreetmap connected!")
    this.#displayMap();
  }

  #displayMap() {
    // Variables
    let markersTable = [];
 
    // We create a new map
    this.map = L.map(this.mapTarget).setView([this.centerValue[0].lat, this.centerValue[0].lon], 6);
    
    // We display the tile layer
    /*
    // Standard map
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(this.map);
    */
    // Topographic Map
    L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', { maxZoom: 17, attribution: 'Map data: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'}).addTo(this.map);

    // We display the homebase marker
    var marker = L.marker([this.centerValue[0].lat, this.centerValue[0].lon]).addTo(this.map);

    // We display a circle radius representing the chosen distance
    var circle = L.circle([this.centerValue[0].lat, this.centerValue[0].lon], {
      color: '#FF8600',
      fillColor: '#FF8600',
      fillOpacity: 0.2,
      radius: this.radiusValue
    }).addTo(this.map);

    // We display the destination airports markers and assign a popup
    this.markersValue.forEach((airport) => {
      // We create a marker for each airport
      //var marker = L.marker([airport.lat, airport.lon]).addTo(this.map);
      var iconDestination = L.icon({
      iconUrl: airport.image_url,
      iconSize:     [50, 50], // size of the icon
      iconAnchor:   [25, 49], // point of the icon which will correspond to marker's location
      popupAnchor:  [0, -50] // point from which the popup should open relative to the iconAnchor
      });

      marker = L.marker([airport.lat, airport.lon], {icon: iconDestination}).addTo(this.map);

      // We add the marker to a table in order used to fit the view on the markers
      markersTable.push(marker);

      // We add a popup to each marker
      marker.bindPopup(airport.info_window).openPopup();
    });

    // We create a group representating the featureBounds object
    var group = new L.featureGroup(markersTable);

    // We adapt the zoom on the group
    this.map.fitBounds(group.getBounds().pad(0.5));
  }
  
  #disconnect(){
    this.map.remove()
  }
}


