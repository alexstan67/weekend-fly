import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "output" ];

  connect() {
    console.log("Clock connected!");
    this.digitalClock();
  }

  digitalClock() {
    var date = new Date;
    var hour = date.getHours();
    var min = date.getMinutes();
    var sec = date.getSeconds();
    console.log(date);
    hour = this.updateTime(hour);
    min = this.updateTime(min);
    sec = this.updateTime(sec);
    this.outputTarget.innerText = hour + ":" + min + ":" + sec;
    //var t = setTimeout(this.digitalClock(), 1000);
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
