import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["step", "prevButton", "nextButton", "submitButton", "input"];
  currentStepIndex = 0;

  connect() {
    this.updateBtnVisibility();
    this.updateTabs(this.currentStepIndex + 1);
    this.element.addEventListener("keydown", this.handleKeyDown.bind(this));
    this.validateInputs();
    this.inputTargets.forEach((input) => {
      input.addEventListener("input", this.validateInputs.bind(this));
      input.addEventListener("change", this.validateInputs.bind(this));
    });
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeyDown.bind(this));
    this.inputTargets.forEach((input) => {
      input.removeEventListener("input", this.validateInputs.bind(this));
      input.removeEventListener("change", this.validateInputs.bind(this));
    });
  }

  handleKeyDown(event) {
    if (event.key === "Enter" && this.validateInputs()) {
      if (this.currentStepIndex < this.stepTargets.length - 1) {
        event.preventDefault();
        this.nextStep();
      }
    }
  }

  nextStep() {
    if (this.currentStepIndex < this.stepTargets.length - 1) {
      this.animateSteps(this.currentStepIndex, this.currentStepIndex + 1);
      this.currentStepIndex++;
      this.updateBtnVisibility();
      this.validateInputs();
    }
  }

  previousStep() {
    if (this.currentStepIndex > 0) {
      this.animateSteps(this.currentStepIndex, this.currentStepIndex - 1);
      this.currentStepIndex--;
      this.updateBtnVisibility();
      this.validateInputs();
    }
  }

  animateSteps(currentIndex, nextIndex) {
    const currentStep = this.stepTargets[currentIndex];
    const nextStep = this.stepTargets[nextIndex];

    if (nextIndex > currentIndex) {
      currentStep.classList.add("translate-x-[-100%]");
      currentStep.classList.remove("translate-x-0");

      nextStep.classList.add("translate-x-0");
      nextStep.classList.remove("translate-x-full");
    } else {
      currentStep.classList.add("translate-x-full");
      currentStep.classList.remove("translate-x-0");

      nextStep.classList.add("translate-x-0");
      nextStep.classList.remove("translate-x-[-100%]");
    }

    this.updateTabs(nextIndex);
  }

  updateTabs(index) {
    const tabsController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="tabs-form-new-trip"]'),
      "tabs-form-new-trip"
    );
    if (tabsController) {
      tabsController.activateTab({ detail: { index: index } });
    }
  }

  updateBtnVisibility() {
    if (this.currentStepIndex > 0) {
      this.prevButtonTarget.classList.remove("hidden");
    } else {
      this.prevButtonTarget.classList.add("hidden");
    }

    if (this.currentStepIndex < this.stepTargets.length - 1) {
      this.nextButtonTarget.classList.remove("hidden");
      this.nextButtonTarget.classList.add("block");
      this.submitButtonTarget.classList.add("hidden");
    } else {
      this.nextButtonTarget.classList.add("hidden");
      this.submitButtonTarget.classList.remove("hidden");
    }
  }

  validateInputs() {
    const currentStep = this.stepTargets[this.currentStepIndex];
    const requiredInputs = currentStep.querySelectorAll("input[required]");
    const allValid = Array.from(requiredInputs).every((input) => input.value.trim() !== "");

    if (allValid) {
      this.nextButtonTarget.disabled = false;
      this.nextButtonTarget.classList.remove("opacity-50", "cursor-not-allowed");
    } else {
      this.nextButtonTarget.disabled = true;
      this.nextButtonTarget.classList.add("opacity-50", "cursor-not-allowed");
    }

    return allValid;
  }
}
