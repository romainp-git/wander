import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "overlay"];

  connect() {
    this.isOpen = false;
  }

  toggle() {
    this.isOpen = !this.isOpen;
    this.updateMenuState();
  }

  updateMenuState() {
    if (this.isOpen) {
      this.menuTarget.classList.remove("translate-x-full");
      this.overlayTarget.classList.remove("hidden");
    } else {
      this.menuTarget.classList.add("translate-x-full");
      this.overlayTarget.classList.add("hidden");
    }
  }
}
