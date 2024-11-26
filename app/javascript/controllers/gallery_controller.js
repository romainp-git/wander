import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mainImage", "modal", "modalImage"];

  showImage(event) {
    const imageUrl = event.currentTarget.querySelector("img").dataset.imageUrl;

    if (imageUrl) {
      // Change l'image principale
      this.mainImageTarget.src = imageUrl;

      // Ouvre la modal si souhaité (facultatif)
      // this.openModal(imageUrl);
    }
  }

  openModal(imageUrl) {
    this.modalImageTarget.src = imageUrl;
    this.modalTarget.classList.add("modal-open");
  }

  closeModal() {
    this.modalTarget.classList.remove("modal-open");
    this.modalImageTarget.src = "";
  }
}
