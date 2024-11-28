import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mapView", "agendaView", "mapToggle", "agendaToggle", "slider"];

  connect() {
    console.log("controller toggle actif");
    this.showMap();

  }

  toggle(event) {
    const view = event.currentTarget.dataset.view;

    if (view === "map") {
      this.showMap();
    } else if (view === "agenda") {
      this.showAgenda();
    }
  }

  showMap() {
    this.sliderTarget.style.transform = "translateX(0%)";

    this.agendaViewTarget.classList.replace("flex", "hidden");
    this.mapViewTarget.classList.replace("hidden", "block");

    this.agendaToggleTarget.classList.replace("text-gray-800", "text-white");
    this.mapToggleTarget.classList.replace("text-white", "text-gray-800");
  }

  showAgenda() {
    this.sliderTarget.style.transform = "translateX(100%)";

    this.mapViewTarget.classList.replace("block", "hidden");
    this.agendaViewTarget.classList.replace("hidden", "flex");

    this.mapToggleTarget.classList.replace("text-gray-800", "text-white");
    this.agendaToggleTarget.classList.replace("text-white", "text-gray-800");
  }
}
