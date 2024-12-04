import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["card", "deleteButton"];

  connect() {
    this.startX = 0;
    this.currentX = 0;
    this.threshold = -10; // Distance pour valider le swipe
  }

  // Début du swipe
  touchstart(event) {
    this.startX = event.touches[0].clientX;
  }

  // Gestion du déplacement
  touchmove(event) {
    this.currentX = event.touches[0].clientX;
    const deltaX = this.currentX - this.startX;

    // Ne gérer que le glissement vers la gauche
    if (deltaX < 0) {
      this.cardTarget.style.transform = `translateX(${deltaX}px)`;
    }
  }

  touchend() {
    const deltaX = this.currentX - this.startX;
    if (deltaX < this.threshold) {
      this.showDeleteButton();
    } else {
      this.resetCard();
    }
  }

  showDeleteButton() {
    this.cardTarget.style.transform = `translateX(-35%)`;
    this.deleteButtonTarget.classList.add("flex");
  }

  resetCard() {
    this.cardTarget.style.transform = `translateX(0)`;
    this.deleteButtonTarget.classList.remove("flex");
  }

  async delete() {
    if (confirm("Voulez-vous vraiment supprimer cet élément ?")) {
      const deleteUrl = this.element.dataset.sortableUpdateUrl; // Récupérer l'URL DELETE
      try {
        const response = await fetch(deleteUrl, {
          method: "DELETE",
          headers: {
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
            "Content-Type": "application/json",
          },
        });

        if (response.ok) {
          this.element.remove(); // Supprimer l'élément du DOM
        } else {
          console.error("Erreur lors de la suppression :", response.statusText);
          alert("Une erreur est survenue. Veuillez réessayer.");
        }
      } catch (error) {
        console.error("Erreur réseau :", error);
        alert("Impossible de supprimer l'élément. Vérifiez votre connexion.");
      }
    }
  }
}
