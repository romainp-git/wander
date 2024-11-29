import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["step", "prevButton"];
  currentStepIndex = 0;

  connect() {
    this.updateBtnVisibility();
    this.updateTabs(this.currentStepIndex + 1);
  }

  nextStep() {
    if (this.currentStepIndex < this.stepTargets.length - 1) {
      this.animateSteps(this.currentStepIndex, this.currentStepIndex + 1);
      this.currentStepIndex++;
      this.updateBtnVisibility();
    }
  }

  previousStep() {
    if (this.currentStepIndex > 0) {
      this.animateSteps(this.currentStepIndex, this.currentStepIndex - 1);
      this.currentStepIndex--;
      this.updateBtnVisibility();
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
  }

  goBack(event) {
    const url = event.currentTarget.dataset.url || "/trips";
    window.location.href = url;
  }
}
