import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["options", "mainButton"];

  connect() {
    this.expanded = false; // Track if the options are expanded
  }

  toggleOptions() {
    if (this.expanded) {
      this.hideOptions();
    } else {
      this.showOptions();
    }
    this.expanded = !this.expanded;
  }

  showOptions() {
    // Reveal option buttons with animation
    this.optionsTarget.classList.remove("hidden", "opacity-0", "translate-y-4");
    this.optionsTarget.classList.add("flex", "opacity-100", "translate-y-0");

    // Change main button to 'close' state
    this.mainButtonTarget.textContent = "close"; // Change icon to close
    this.mainButtonTarget.classList.remove("bg-orange-500");
    this.mainButtonTarget.classList.add("bg-red-500");
  }

  hideOptions() {
    // Hide option buttons
    this.optionsTarget.classList.add("opacity-0", "translate-y-4");
    this.optionsTarget.classList.remove("opacity-100", "translate-y-0");

    // Wait for animation to finish before hiding the options completely
    setTimeout(() => {
      this.optionsTarget.classList.add("hidden");
    }, 300); // Match the duration of your Tailwind animation (300ms)

    // Reset main button to 'add' state
    this.mainButtonTarget.textContent = "Add"; // Reset icon to add
    this.mainButtonTarget.classList.remove("bg-red-500");
    this.mainButtonTarget.classList.add("bg-orange-500");
  }
}
