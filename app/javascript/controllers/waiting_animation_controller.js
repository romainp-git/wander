import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    const items = document.querySelectorAll(".animation-item");
    console.log(items);
    let timeouts = [];

    items.forEach((item, index) => {
      timeouts.push(setTimeout(() => {
        item.classList.replace("opacity-0", "opacity-100");
        item.classList.replace("translate-y-40", "translate-y-0");
      }, index * 1000));
    });
  }

  disconnect() {
    for (var i = 0; i < timeouts.length; i++) {
      clearTimeout(timeouts[i]);
    }
    timeouts = [];
  }
}
