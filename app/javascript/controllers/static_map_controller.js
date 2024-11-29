import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    apiKey: String,
    isoCodes: Array,
  };
  static targets = ["static-map"];

  connect() {
    console.log(this.isoCodesValue)
    mapboxgl.accessToken = this.apiKeyValue;
    const map = new mapboxgl.Map({
      container: 'static-map',
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [5, 46],
      zoom: 0
    });

    const controller = this

    map.on('load', function() {
      map.addLayer(
        {
          id: 'country-boundaries',
          source: {
            type: 'vector',
            url: 'mapbox://mapbox.country-boundaries-v1',
          },
          'source-layer': 'country_boundaries',
          type: 'fill',
          paint: {
            'fill-color': '#d2361e',
            'fill-opacity': 0.4,
          },
        },
        'country-label'
      );
      const countries = [
        "in",
        "iso_3166_1_alpha_3"
      ]
      controller.isoCodesValue.forEach((isoCode) =>
        countries.push(isoCode)
      )
      console.log(countries)
      map.setFilter('country-boundaries', countries);
    });
  }
}
