import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    markers: Array
  }

  static targets = [ 'map' ]

  connect() {
    console.log("Openstreetmap connected!")
    // We create a new map
    this.map = L.map(this.mapTarget).setView([51.505, -0.09], 13);
    
    // We display the tile layer
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(this.map);
  }

  disconnect(){
    this.map.remove()
  }
}
