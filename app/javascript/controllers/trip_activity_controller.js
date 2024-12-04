import { Controller } from "@hotwired/stimulus";
import { createConsumer } from "@rails/actioncable";

export default class extends Controller {
  static values = { id: Number };

  connect() {
    console.log(this.idValue);
    this.subscription = createConsumer().subscriptions.create(
      { channel: "TripActivitiesChannel", id: this.idValue },
      {
        received: (data) => {
          console.log("Received HTML:", data.html);
          const tripActivityElement = document.getElementById(`trip_activity_${data.trip_activity_id}`);
          if (tripActivityElement) {
            tripActivityElement.innerHTML = data.html;
            console.log("Updated DOM element:", tripActivityElement);
          } else {
            console.warn("Element not found for trip_activity_id:", data.trip_activity_id);
          }
        },
      }
    );
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }
}
