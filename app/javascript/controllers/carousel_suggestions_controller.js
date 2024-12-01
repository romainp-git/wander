import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item"];

  connect() {
    this.carousel = this.element;

    if (this.itemTargets.length > 0) {
      this.itemTargets[0].classList.add("scale-100");
    }

    this.updateActiveItem();
    this.carousel.addEventListener("scroll", this.updateActiveItem.bind(this));

    this.input = document.querySelector("input[name='search[destination]']");
    this.itemTargets.forEach((item) => {
      item.addEventListener("click", this.setDestination.bind(this));
    });
  }

  setDestination(event) {
    const item = event.currentTarget;
    const value = item.dataset.value;

    if (event.target.closest("a[data-turbo-frame='modal-frame']")) {
      return;
    }

    if (item.dataset.clickable === "true") {
      const value = item.dataset.value;
      if (this.input) {
        this.input.value = value;
      }
    }
  }

  updateActiveItem() {
    const carouselRect = this.carousel.getBoundingClientRect();
    const centerThreshold = 0.1;

    const centerLeft = carouselRect.left + carouselRect.width * centerThreshold;
    const centerRight = carouselRect.right - carouselRect.width * centerThreshold;

    this.itemTargets.forEach((item, index) => {
      const itemRect = item.getBoundingClientRect();

      const isCentered =
        itemRect.left >= centerLeft && itemRect.right <= centerRight;

      if (isCentered) {
        item.classList.replace("scale-95", "scale-100");
        item.classList.replace("opacity-75", "opacity-100");
        item.dataset.clickable = "true";
        if (index !== 0 && this.itemTargets[0].classList.contains("scale-100")) {
          this.itemTargets[0].classList.replace("scale-100", "scale-95");
          this.itemTargets[0].classList.replace("opacity-100", "opacity-75");
          this.itemTargets[0].dataset.clickable = "false";
        }
      /*}  else if (index === 0) {
        const isSecondCentered =
          this.itemTargets[1]?.getBoundingClientRect().left >= centerLeft &&
          this.itemTargets[1]?.getBoundingClientRect().right <= centerRight;

        if (!isSecondCentered) {
          this.itemTargets[0].classList.replace("scale-95", "scale-100");
          this.itemTargets[0].classList.replace("opacity-75", "opacity-100");
          this.itemTargets[0].dataset.clickable = "true";
        } */
      } else if (index !== 0) {
        item.classList.replace("scale-100", "scale-95");
        item.classList.replace("opacity-100", "opacity-75");
        item.dataset.clickable = "false";
      }
    });
  }
}
