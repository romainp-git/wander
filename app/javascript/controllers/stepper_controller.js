import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("stepper_controller");

    const steps = document.querySelectorAll(".step");
    this.curr_step = 1;

    document.querySelectorAll(".next-step").forEach((button) => {
      button.addEventListener("click", () => {
        const nextStep = parseInt(button.dataset.nextStep, 10);
        this.goToStep(nextStep);
      });
    });

    document.querySelectorAll(".prev-step").forEach((button) => {
      button.addEventListener("click", () => {
        const prevStep = parseInt(button.dataset.prevStep, 10);
        this.goToStep(prevStep);
      });
    });

    document.querySelectorAll("input.required").forEach((input) => {
      input.addEventListener("input", () => this.updateNextButtonState());
    });

    document.addEventListener("keydown", (event) => {
      if (event.key === "Enter") {
        event.preventDefault();
        //this.curr_step += 1;
        //this.goToStep(this.curr_step);
      }
    });

    this.goToStep(this.curr_step);
    this.updateNextButtonState()
  }

  updateNextButtonState() {
    const currentStep = document.querySelector(`.step[data-step="${this.curr_step}"]`);
    console.log(currentStep)
    const requiredFields = currentStep.querySelectorAll("input.required");
    const nextButton = currentStep.querySelector(".next-step");

    // Vérifie si tous les champs "required" ont une valeur non vide
    const allFieldsValid = Array.from(requiredFields).every((input) => input.value.trim() !== "");

    if (nextButton) {
      nextButton.disabled = !allFieldsValid; // Active ou désactive le bouton
    }
  }

  goToStep(stepIndex) {
    this.curr_step = stepIndex;

    const tabsController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="tabs-form-new-trip"]'),
      "tabs-form-new-trip"
    );
    if (tabsController) {
      tabsController.activateTab({ detail: { index: stepIndex } });
    }

    const steps = document.querySelectorAll(".step");
    const summary = document.getElementById("summary");

    steps.forEach((step, index) => {
      step.classList.toggle("hidden", index + 1 !== stepIndex);
    });
  }


}
