import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["splash"]

  connect() {
    const splashScreen = document.getElementById("splash-screen");
    splashScreen.style.display = "flex";

    setTimeout(() => {
      splashScreen.style.display = "none";
      sessionStorage.setItem("splashShown", "true");
    }, 3000);
  }
}
