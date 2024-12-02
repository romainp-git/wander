import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
    assetsPath: String
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/standard",
      projection: "mercator",
      zoom: 1
    });

    this.markerElements = [];
    this.markersValue.forEach((marker, index) => {
      const el = document.createElement("div");
      el.addEventListener("click", () => {
        this.highlightMarker(index);
        window.dispatchEvent(new CustomEvent("scrollToItem", { detail: { index } }));
      });
      el.className = "marker icon icon-filled icon-40";
      const iconUrl = `/images/${marker.category}.png`;
      el.style.backgroundImage = `url('${iconUrl}')`;
      el.style.width = "60px";
      el.style.height = "60px";
      el.style.backgroundSize = "cover";
      // el.textContent = "location_on";
      // el.style.color = "#ffffff";
      el.style.cursor = "pointer";
      el.style.transform = "translate(-50%, -100%)";
      el.dataset.index = index;

      this.markerElements.push(el);

      new mapboxgl.Marker(el)
        .setLngLat([marker.lng, marker.lat])
        .addTo(this.map);
    });

    if (this.markersValue.length) {
      this.highlightMarker(0);
    }

    window.addEventListener("highlight", (event) => {
      console.log("Événement 'highlight' capté au niveau global :", event.detail);
      this.highlightMarker(event.detail.index);
    });
  }

  highlightMarker(index) {
    const marker = this.markersValue[index];
    const heightOffset = (window.innerHeight / 3) - (window.innerHeight / 2);

    if (!marker) return;
    this.map.flyTo({
      center: [marker.lng, marker.lat],
      zoom: 15,
      offset: [0, heightOffset]
    });
    this.markerElements.forEach((el, i) => {
      if (i === index) {
        el.style.color = "#ea580c";
      } else {
        el.style.color = "#ffffff";
      }
    });
  }
}
