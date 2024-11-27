import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabs"];

  connect() {
    console.log("tabs_form_new_trip_controller");
  }

  activateTab(event) {
    this.tabsTargets.forEach((content) => {
      content.classList.replace("bg-white", "border");
    });

    console.log(event.detail.index);
    const targetIndex = event.detail.index;
    this.tabsTargets[targetIndex].classList.replace("border", "bg-white");
  }
}
