import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "item"];

  connect() {
    console.log("Carrousel controller connecté");

    this.carousel = this.element;
    this.onScroll();
    this.carousel.addEventListener("scroll", this.onScroll.bind(this));

    window.addEventListener("scrollToItem", (event) => {
      this.scrollToItem(event.detail.index);
    });
  }

  scrollToItem(index) {
    const target = this.itemTargets[index];
    if (target) {
      this.carousel.scrollTo({
        left: (target.offsetLeft - 34) - this.carousel.offsetLeft,
        behavior: "smooth",
      });
    }
  }

  onScroll() {
    console.log("Défilement détecté dans le carrousel");
    const carouselRect = this.carousel.getBoundingClientRect();

    this.itemTargets.forEach((item) => {
      const itemRect = item.getBoundingClientRect();
      const isCentered =
        itemRect.left >= carouselRect.left &&
        itemRect.right <= carouselRect.right;

      if (isCentered) {
        const index = parseInt(item.dataset.carouselIndexValue, 10);
        console.log("Élément centré détecté :", index);
        window.dispatchEvent(
          new CustomEvent("highlight", { detail: { index } })
        );
      }
    });
  }


  disconnect() {
    this.carousel.removeEventListener("scroll", this.onScroll.bind(this));
  }
}
