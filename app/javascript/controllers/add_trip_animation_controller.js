import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text", "titlePart", "formPart", "pulseButton", "tabs", "buttons"];

  connect() {
    console.log("add_trip_controller");
    this.text = `J'ai besoin de quelques informations pour créer votre programme.`;
    this.index = 0;
    setTimeout(() => this.typeWriter(), 500);
  }

  typeWriter() {
    if (this.index < this.text.length) {
      const currentChar = this.text.charAt(this.index);
      if (currentChar === "\n") {
        this.textTarget.innerHTML += "<br>";
      } else {
        this.textTarget.innerHTML += currentChar;
      }
      this.index++;
      setTimeout(() => this.typeWriter(), 30);
    } else {
      setTimeout(() => {
        this.titlePartTarget.classList.replace("mt-title", "mt-10");
        this.pulseButtonTarget.classList.add("opacity-0");
        this.tabsTarget.classList.replace("opacity-0", "opacity-100");

        setTimeout(() => {
          this.pulseButtonTarget.classList.add("hidden");
          this.formPartTarget.classList.remove("opacity-0");
          this.buttonsTarget.classList.remove("opacity-0");
        }, 1000);
      }, 500);
    }
  }
}
