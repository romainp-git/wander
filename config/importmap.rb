# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "mapbox-gl", to: "https://api.mapbox.com/mapbox-gl-js/v3.8.0/mapbox-gl.js"
pin "flatpickr" # @4.6.13
pin "flatpickr-l10n-fr", to: "https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/fr.js"
pin_all_from "app/javascript/controllers", under: "controllers"
