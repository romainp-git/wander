import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  connect() {
    this.isOpen = false;
  }

  toggle() {
    this.isOpen = !this.isOpen;
    this.updateMenuState();
  }

  updateMenuState() {
    if (this.isOpen) {
      this.menuTarget.classList.remove("-translate-x-full");
    } else {
      this.menuTarget.classList.add("-translate-x-full");
    }
  }

  close(event) {
    if (this.isOpen && !this.menuTarget.contains(event.target)) {
      this.isOpen = false;
      this.updateMenuState();
    }
  }
}
