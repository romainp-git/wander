import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "item", "progressBar"];

  connect() {
    console.log("stories connect");
    this.slides = this.itemTargets;
    this.progressBars = this.progressBarTargets;
    this.slideCount = this.slides.length;
    this.currentIndex = 0;
    this.slideDuration = 5000;

    this.progressBars.forEach((bar, i) => {
      bar.style.transition = "none";
      bar.style.width = "0%";
    });

    this.startCarousel();
  }

  disconnect() {
    this.stopAutoplay();
    console.log("disconnect");
  }

  startCarousel() {
    this.goToSlide(0);
    this.autoplay();
  }

  goToSlide(index) {
    this.trackTarget.style.transform = `translateX(-${index * 100}%)`;
    this.currentIndex = index;

    setTimeout(() => {
      const currentBar = this.progressBars[index];
      currentBar.style.transition = `width ${this.slideDuration}ms linear`;
      currentBar.style.width = "100%";
    }, 10);

    if (index === this.slideCount - 1) {
      this.stopAutoplay();
    }
  }

  autoplay() {
    this.autoplayInterval = setInterval(() => {
      const nextIndex = (this.currentIndex + 1) % this.slideCount;
      this.goToSlide(nextIndex);
    }, this.slideDuration);
  }

  startAutoplay() {
    if (!this.autoplayInterval) {
      this.autoplay();
    }
  }

  stopAutoplay() {
    if (this.autoplayInterval) {
      clearInterval(this.autoplayInterval);
      this.autoplayInterval = null;
      console.log(this.autoplayInterval)
    }
  }
}
