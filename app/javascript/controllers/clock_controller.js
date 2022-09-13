import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "output" ];

  connect() {
    console.log("Clock connected!");
    this.digitalClock();
  }

  digitalClock() {
    var date = new Date();
    
    var day = date.getUTCDate();
    var month = date.getUTCMonth() + 1
    var year = date.getUTCFullYear();
    var hour = date.getUTCHours();
    var min = date.getUTCMinutes();
    
    day = this.updateTime(day);
    month = this.updateTime(month);
    hour = this.updateTime(hour);
    min = this.updateTime(min);
    
    this.outputTarget.innerText = day + "-" + month + "-" + year + " | " + hour + ":" + min + " UTC";
    setInterval(() => {
      this.digitalClock()
    }, 30000);
  }

  updateTime(k) {
    if (k < 10) {
      return "0" + k;
    }
    else {
      return k;
    }
  }

}
