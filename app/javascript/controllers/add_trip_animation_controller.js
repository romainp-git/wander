import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text", "titlePart", "calendarPart", "pulseButton"];

  connect() {
    console.log("add_trip_controller");
    this.text = "Hi, I'm Wander, your personal assistant. I need to ask you some questions for your future trip.";
    this.index = 0;
    setTimeout(() => this.typeWriter(), 500);
  }

  typeWriter() {
    if (this.index < this.text.length) {
      this.textTarget.innerHTML += this.text.charAt(this.index);
      this.index++;
      setTimeout(() => this.typeWriter(), 30);
    } else {
      setTimeout(() => {
        this.titlePartTarget.style.marginTop = "10px";
        this.pulseButtonTarget.classList.add("opacity-0");

        setTimeout(() => {
          this.pulseButtonTarget.classList.add("hidden");
          this.calendarPartTarget.classList.replace("opacity-0", "opacity-100");
        }, 1000);
      }, 500);
    }
  }
}
