import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["mapView", "agendaView", "mapToggle", "agendaToggle"];

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
    this.mapViewTarget.classList.remove("hidden");
    this.mapViewTarget.classList.add("block");

    this.agendaViewTarget.classList.add("hidden");
    this.agendaViewTarget.classList.remove("block");

    this.mapToggleTarget.classList.add("bg-gray-800", "text-white");
    this.mapToggleTarget.classList.remove("bg-white", "text-gray-800");

    this.agendaToggleTarget.classList.add("bg-white", "text-gray-800");
    this.agendaToggleTarget.classList.remove("bg-gray-800", "text-white");
  }

  showAgenda() {
    this.agendaViewTarget.classList.remove("hidden");
    this.agendaViewTarget.classList.add("block");

    this.mapViewTarget.classList.add("hidden");
    this.mapViewTarget.classList.remove("block");

    this.agendaToggleTarget.classList.add("bg-gray-800", "text-white");
    this.agendaToggleTarget.classList.remove("bg-white", "text-gray-800");

    this.mapToggleTarget.classList.add("bg-white", "text-gray-800");
    this.mapToggleTarget.classList.remove("bg-gray-800", "text-white");
  }
}
