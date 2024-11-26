import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { index: Number };

  connect() {

    this.items = this.element.querySelectorAll(".carousel-item");
  }

  select(event) {
    const index = event.currentTarget.dataset.carouselIndexValue;
    console.log(`Dispatch global de l'événement 'highlight' avec l'index : ${index}`);
    window.dispatchEvent(new CustomEvent("highlight", { detail: { index: parseInt(index) } }));
  }
}
