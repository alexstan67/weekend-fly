import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="burger"
export default class extends Controller {
  static targets = [ "menu" ];

  connect() {
    console.log("Burger connected!");
  }

  menu() {
    this.menuTarget.classList.toggle("show");
  }
}
