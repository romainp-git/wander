import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabs"];

  connect() {
    console.log("tabs_form_new_trip_controller");
  }

  activateTab(event) {
    const targetIndex = event.detail.index + 1;

    this.tabsTargets.forEach((content, index) => {
      if(index > targetIndex) content.classList.remove("step-warning");
      else content.classList.add("step-warning");
    });
  }
}
