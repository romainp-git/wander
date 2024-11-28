import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text", "titlePart", "formPart", "pulseButton"];

  connect() {
    console.log("add_trip_controller");
    this.text = `Bonjour, Je suis Wander 👾, votre assistant personnel de voyage.
    J'ai besoin de quelques informations pour créer votre programme.`;
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
        this.titlePartTarget.style.marginTop = "10px";
        this.pulseButtonTarget.classList.add("opacity-0");

        const tabsController = this.application.getControllerForElementAndIdentifier(
          document.querySelector('[data-controller="tabs-form-new-trip"]'),
          "tabs-form-new-trip"
        );
        if (tabsController) {
          tabsController.activateTab({ detail: { index: 1 } });
        }

        setTimeout(() => {
          this.pulseButtonTarget.classList.add("hidden");
          this.formPartTarget.classList.replace("opacity-0", "opacity-100");
        }, 1000);
      }, 500);
    }
  }
}
