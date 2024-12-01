import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value", "input"];

  connect() {
    console.log("Counter controller connected");
  }

  increment(event) {
    const type = event.currentTarget.dataset.type;
    const valueElement = this.valueTargets.find((el) => el.dataset.type === type);
    const hiddenInput = this.inputTargets.find((input) => input.dataset.type === type);

    let currentValue = parseInt(valueElement.textContent, 10);
    currentValue += 1;

    valueElement.textContent = currentValue;
    hiddenInput.value = currentValue;
  }

  decrement(event) {
    const type = event.currentTarget.dataset.type;
    const valueElement = this.valueTargets.find((el) => el.dataset.type === type);
    const hiddenInput = this.inputTargets.find((input) => input.dataset.type === type);

    let currentValue = parseInt(valueElement.textContent, 10);
    if (currentValue > 0) {
      currentValue -= 1;

      valueElement.textContent = currentValue;
      hiddenInput.value = currentValue;
    }
  }
}
