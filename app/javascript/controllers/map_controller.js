import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/pdunleav/cjofefl7u3j3e2sp0ylex3cyb",
      center: [2.3522, 48.8566],
      zoom: 12
    });

    this.markerElements = [];
    this.markersValue.forEach((marker, index) => {
      const el = document.createElement("div");
      el.addEventListener("click", () => {
        this.highlightMarker(index);
        window.dispatchEvent(new CustomEvent("scrollToItem", { detail: { index } }));
      });
      el.className = "marker";
      el.style.backgroundImage = 'url("https://docs.mapbox.com/help/demos/custom-markers-gl-js/mapbox-icon.png")';
      el.style.width = "30px";
      el.style.height = "30px";
      el.style.backgroundSize = "cover";
      el.dataset.index = index;

      this.markerElements.push(el);

      new mapboxgl.Marker(el)
        .setLngLat([marker.lng, marker.lat])
        .addTo(this.map);
    });

    if (this.markersValue.length) {
      const bounds = new mapboxgl.LngLatBounds();
      this.markersValue.forEach((marker) =>
        bounds.extend([marker.lng, marker.lat])
      );
      this.map.fitBounds(bounds, { padding: 50, maxZoom: 15, duration: 0 });
    }

    window.addEventListener("highlight", (event) => {
      console.log("Événement 'highlight' capté au niveau global :", event.detail);
      this.highlightMarker(event.detail.index);
    });
  }

  highlightMarker(index) {
    const marker = this.markersValue[index];

    if (!marker) return;
    this.map.flyTo({
      center: [marker.lng, marker.lat],
      zoom: 15
    });
    this.markerElements.forEach((el, i) => {
      if (i === index) {
        el.classList.add("bg-yellow-500", "scale-300");
      } else {
        el.classList.remove("bg-yellow-500", "scale-300");
      }
    });
  }
}
