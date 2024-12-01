import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mapView", "agendaView"];

  connect(){
    console.log("show map toggle controller")
  }

  toggleView(event) {
    const view = event.currentTarget.dataset.view;
    console.log(event.currentTarget.dataset)

    if (view === "map") {
      this.showMap();
    } else {
      this.showAgenda();
    }
  }

  showMap() {
    console.log("show map")
    this.mapViewTarget.classList.replace("translate-y-full", "translate-y-[70px]");
  }

  showAgenda() {
    this.mapViewTarget.classList.replace("translate-y-[70px]", "translate-y-full");
  }
}
