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
      style: "mapbox://styles/mapbox/streets-v11",
      center: [2.3522, 48.8566],
      zoom: 12
    });

    this.markerElements = [];
    this.markersValue.forEach((marker, index) => {
      const el = document.createElement("div");
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
    console.log("Index sélectionné :", index); // Log pour vérifier l'index
    console.log("Marqueur correspondant :", marker); // Log pour vérifier le marqueur

    if (!marker) return;

    // Centrer la carte sur le marqueur sélectionné
    this.map.flyTo({
      center: [marker.lng, marker.lat],
      zoom: 15
    });

    // Ajouter une classe pour mettre en surbrillance le marqueur sélectionné
    this.markerElements.forEach((el, i) => {
      if (i === index) {
        el.classList.add("bg-yellow-500", "scale-300");
      } else {
        el.classList.remove("bg-yellow-500", "scale-300");
      }
    });
  }
}
