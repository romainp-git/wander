import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.classList.add("translate-y-full");

    setTimeout(() => {
      this.element.classList.remove("translate-y-full");
      this.element.classList.add("translate-y-0");
    }, 10);
  }

  close() {
    this.element.classList.add("translate-y-full");
    setTimeout(() => {
      const modalFrame = this.element.closest("turbo-frame");
      if (modalFrame) {
        modalFrame.innerHTML = "";
      }
    }, 300);
  }
}
