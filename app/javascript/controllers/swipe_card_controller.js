import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["card", "deleteButton"];

  connect() {
    console.log("swipe controller connected");
    this.startX = 0;
    this.currentX = 0;
    this.threshold = -50;
  }

  touchstart(event) {
    this.startX = event.touches[0].clientX;

    this.deleteButtonTarget.classList.remove("hidden");
  }

  touchmove(event) {
    this.currentX = event.touches[0].clientX;
    const deltaX = this.currentX - this.startX;

    if (deltaX < 0) {
      this.cardTarget.style.transform = `translateX(${deltaX}px)`;
      const progress = Math.min(Math.abs(deltaX) / 100, 1);

      this.deleteButtonTarget.style.opacity = progress.toString();

      this.deleteButtonTarget.style.filter = progress === 1 ? "none" : `blur(${(1 - progress) * 5}px)`;
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
    this.cardTarget.style.transform = `translateX(-30%)`;
    this.deleteButtonTarget.style.opacity = "1";
    this.deleteButtonTarget.style.filter = "none";
    this.deleteButtonTarget.classList.add("flex");
  }

  resetCard() {
    this.cardTarget.style.transform = `translateX(0)`;
    this.deleteButtonTarget.style.opacity = "0";
    this.deleteButtonTarget.style.filter = "blur(5px)";
    setTimeout(() => {
      this.deleteButtonTarget.classList.add("hidden");
    }, 300);
  }

  async delete() {
    if (confirm("Voulez-vous vraiment supprimer cette activité ?")) {
      const deleteUrl = this.element.dataset.sortableUpdateUrl;

      try {
        const response = await fetch(deleteUrl, {
          method: "DELETE",
          headers: {
            "Content-Type": "application/json",
          },
        });

        if (response.ok) {
          this.element.remove();
        } else {
          alert("Une erreur est survenue. Veuillez réessayer.");
        }
      } catch (error) {
        alert("Impossible de supprimer l'activité. Vérifiez votre connexion.");
      }
    }
  }
}
