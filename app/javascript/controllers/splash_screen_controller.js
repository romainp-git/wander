import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["splash", "main"]

  connect() {
    const splashScreen = document.getElementById("splash-screen");
    const mainContent = document.getElementById("home-content");

    splashScreen.style.display = "flex";
    setTimeout(() => {
      splashScreen.style.display = "none";
      mainContent.style.opacity = 1;
      sessionStorage.setItem("splashShown", "true");
    }, 3000);
  }
}
