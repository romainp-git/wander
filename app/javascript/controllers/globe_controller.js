import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="globe"
export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  };

  static targets = ["map"];

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      center: [2.3522, 48.8566],
      style: 'mapbox://styles/mapbox/satellite-v9',
      attributionControl: false,
      projection: 'globe',
      zoom: 1.5,
    });


    this.map.on('style.load', () => { this.map.setFog({}); });
    this.setupGlobeRotation();
  }

  setupGlobeRotation() {
    const secondsPerRevolution = 120;
    const maxSpinZoom = 5;
    const slowSpinZoom = 3;

    let userInteracting = false;
    let spinEnabled = true;

    const spinGlobe = () => {
      const zoom = this.map.getZoom();
      if (spinEnabled && !userInteracting && zoom < maxSpinZoom) {
        let distancePerSecond = 360 / secondsPerRevolution;
        if (zoom > slowSpinZoom) {
          const zoomDif =
            (maxSpinZoom - zoom) / (maxSpinZoom - slowSpinZoom);
          distancePerSecond *= zoomDif;
        }
        const center = this.map.getCenter();
        center.lng -= distancePerSecond;
        this.map.easeTo({ center, duration: 1000, easing: (n) => n });
      }
    };

    this.map.on('mousedown', () => { userInteracting = true; });
    this.map.on('mouseup', () => { userInteracting = false; spinGlobe(); });
    this.map.on('dragend', () => { userInteracting = false; spinGlobe(); });
    this.map.on('pitchend', () => { userInteracting = false; spinGlobe(); });
    this.map.on('rotateend', () => { userInteracting = false; spinGlobe(); });
    this.map.on('moveend', () => { spinGlobe(); });

    spinGlobe();
  }
}
