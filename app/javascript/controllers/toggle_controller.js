import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mapView", "agendaView", "mapToggle", "agendaToggle", "slider"];

  connect() {
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

    this.mapViewTarget.classList.remove("hidden");
    this.mapViewTarget.classList.add("block");

    this.agendaViewTarget.classList.replace("flex", "hidden");

    this.agendaToggleTarget.classList.remove("text-gray-800");
    this.agendaToggleTarget.classList.add("text-white");
    this.mapToggleTarget.classList.add("text-gray-800");
    this.mapToggleTarget.classList.remove("text-white");
  }


  showAgenda() {
    this.sliderTarget.style.transform = "translateX(100%)";

    this.agendaViewTarget.classList.replace("hidden", "flex");

    this.mapViewTarget.classList.add("hidden");
    this.mapViewTarget.classList.remove("block");

    this.mapToggleTarget.classList.add("text-white");
    this.mapToggleTarget.classList.remove("text-gray-800");
    this.agendaToggleTarget.classList.remove("text-white");
    this.agendaToggleTarget.classList.add("text-gray-800");
  }
}
