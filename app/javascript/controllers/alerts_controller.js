import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button" ];

  connect() {
    console.log("alerts_controller.js connected");
  }
  close() {
    console.log("Button click");
    this.buttonTarget.parentNode.removeChild(this.buttonTarget);
  }
}
