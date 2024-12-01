import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds"];
  static values = { startDate: String };

  connect() {
    this.startDate = new Date(this.startDateValue);
    this.updateCountdown();
    this.timer = setInterval(() => this.updateCountdown(), 1000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  updateCountdown() {
    const now = new Date();
    const timeLeft = this.startDate - now;

    if (timeLeft <= 0) {
      this.stopCountdown();
      return;
    }

    const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
    const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);

    this.daysTarget.textContent = days;
    this.hoursTarget.textContent = hours.toString().padStart(2, "0");
    this.minutesTarget.textContent = minutes.toString().padStart(2, "0");
    this.secondsTarget.textContent = seconds.toString().padStart(2, "0");
  }

  stopCountdown() {
    clearInterval(this.timer);
    this.daysTarget.textContent = "0";
    this.hoursTarget.textContent = "00";
    this.minutesTarget.textContent = "00";
    this.secondsTarget.textContent = "00";
  }
}
