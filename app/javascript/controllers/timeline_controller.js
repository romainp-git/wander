import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.resizeObserver = new ResizeObserver(() => {
      this.adjustHeight();
    });

    this.resizeObserver.observe(this.containerTarget);

    this.adjustHeight();
    window.addEventListener("resize", this.adjustHeight.bind(this));
  }

  disconnect() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
    window.removeEventListener("resize", this.adjustHeight.bind(this));
  }

  adjustHeight() {
    this.containerTargets.forEach((container) => {
      const timeline = container.querySelector("[data-dynamic-height]");
      const listItems = container.querySelectorAll("li");

      if (timeline && listItems.length > 0) {
        const firstItemHeight = (listItems[0].offsetHeight + 16) / 2;
        const lastItemHeight = (listItems[listItems.length - 1].offsetHeight + 16) / 2;
        const dynamicHeight = container.offsetHeight - firstItemHeight - lastItemHeight;
        const topPosition = (container.offsetHeight - dynamicHeight) / 2;

        timeline.style.height = `${dynamicHeight}px`;
        timeline.style.top = `${topPosition}px`;
      }
    });
  }
}
