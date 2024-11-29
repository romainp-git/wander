# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "mapbox-gl", to: "https://api.mapbox.com/mapbox-gl-js/v3.8.0/mapbox-gl.js"
pin "flatpickr" # @4.6.13
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@stimulus-components/read-more", to: "@stimulus-components--read-more.js" # @5.0.0
pin "@rails/actioncable", to: "@rails--actioncable.js" # @8.0.0
