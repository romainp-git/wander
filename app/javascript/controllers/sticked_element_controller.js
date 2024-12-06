import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["card", "container"];

  connect() {
    console.log("Sticky controller connected");

    this.intersectionObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.containerTarget.classList.remove("sticked");
          } else {
            this.containerTarget.classList.add("sticked");
          }
        });
      },
      { threshold: [1] }
    );

    this.intersectionObserver.observe(this.containerTarget);

    this.mutationObserver = new MutationObserver(() => {
      this.applyStacking();
    });

    this.mutationObserver.observe(this.containerTarget, {
      attributes: true,
      childList: true,
      subtree: false,
      attributeFilter: ["style"],
    });

    setTimeout(() => {
      console.log("Delayed applyStacking called");
      this.applyStacking();
    }, 100);

    this.applyStacking();
    window.addEventListener("resize", this.applyStacking.bind(this));
  }

  disconnect() {
    console.log("Sticky controller disconnected");

    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
    }
    if (this.mutationObserver) {
      this.mutationObserver.disconnect();
    }

    window.removeEventListener("resize", this.applyStacking.bind(this));
  }

  applyStacking() {
    const baseTop = this.containerTarget.offsetHeight - 20;
    const increment = 20;

    this.cardTargets.forEach((card, index) => {
      const dynamicTop = baseTop + index * increment;
      console.log(`Card ${index}: baseTop=${baseTop}, dynamicTop=${dynamicTop}`);
      card.style.top = `calc(env(safe-area-inset-top) + ${dynamicTop}px)`;
    });
  }
}
