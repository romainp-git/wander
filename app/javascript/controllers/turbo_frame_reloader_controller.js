import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["turboReload"];

  connect() {
    console.log("turbo frame reloader controller")
    this.reloadFrames();
  }

  reloadFrames() {
    this.turboReloadTargets.forEach((frame) => {
      const src = frame.getAttribute("src");
      console.log(src)
      if (src) {
        frame.src = src;
      }
    });
  }
}
