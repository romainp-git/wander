import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds"];
  static values = { startDate: String };

  connect() {
    this.startDate = new Date(this.startDateValue);
    this.updateTimer();
    this.timer = setInterval(() => this.updateTimer(), 1000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  updateTimer() {
    const now = new Date();
    const timeDifferenceInSeconds = Math.floor((now - this.startDate) / 1000);

    const years = Math.floor(timeDifferenceInSeconds / (365 * 24 * 60 * 60));
    let remainingSeconds = timeDifferenceInSeconds % (365 * 24 * 60 * 60);

    const days = Math.floor(remainingSeconds / (24 * 60 * 60));
    remainingSeconds %= 24 * 60 * 60;

    const hours = Math.floor(remainingSeconds / (60 * 60));
    remainingSeconds %= 60 * 60;

    const minutes = Math.floor(remainingSeconds / 60);
    const seconds = remainingSeconds % 60;

    this.daysTarget.textContent = days;
    this.hoursTarget.textContent = this.padZero(hours);
    this.minutesTarget.textContent = this.padZero(minutes);
    this.secondsTarget.textContent = this.padZero(seconds);
  }

  padZero(value) {
    return String(value).padStart(2, "0");
  }
}
