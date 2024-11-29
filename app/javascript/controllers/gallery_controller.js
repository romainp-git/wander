import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mainImage", "modal", "modalImage", "thumbnail"];

  connect() {
    console.log("gallery controller connected");

    this.currentIndex = 0; // Indice de l'image active
  }

  showImage(event) {
    const thumbnail = event.currentTarget;
    const imageUrl = thumbnail.querySelector("img").dataset.imageUrl;

    if (imageUrl) {
      this.currentIndex = parseInt(thumbnail.dataset.galleryIndex, 10);
      this.updateMainImage(imageUrl);
      this.openModal(imageUrl);
    }
  }

  updateMainImage(imageUrl) {
    this.mainImageTarget.src = imageUrl;
  }

  openModal(imageUrl) {
    this.modalImageTarget.src = imageUrl;
    this.modalTarget.classList.remove("hidden");
  }

  closeModal() {
    this.modalTarget.classList.add("hidden");
    this.modalImageTarget.src = "";
  }

  prevImage() {
    // Décrémenter l'indice
    this.currentIndex =
      (this.currentIndex - 1 + this.thumbnailTargets.length) % this.thumbnailTargets.length;

    // Mettre à jour l'image
    const imageUrl = this.thumbnailTargets[this.currentIndex].querySelector("img").dataset.imageUrl;
    this.modalImageTarget.src = imageUrl;
    this.updateMainImage(imageUrl);
  }

  nextImage() {
    // Incrémenter l'indice
    this.currentIndex = (this.currentIndex + 1) % this.thumbnailTargets.length;

    // Mettre à jour l'image
    const imageUrl = this.thumbnailTargets[this.currentIndex].querySelector("img").dataset.imageUrl;
    this.modalImageTarget.src = imageUrl;
    this.updateMainImage(imageUrl);
  }
}
