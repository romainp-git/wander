import { Controller } from "@hotwired/stimulus";
import { createConsumer } from "@rails/actioncable";

export default class extends Controller {
  connect() {
    console.log("action cable : " + this.element.dataset.loadingSearchId)

    this.subscription = createConsumer().subscriptions.create(
      { channel: "LoadingChannel", search_id: this.element.dataset.loadingSearchId },
      {
        received: (data) => {
          if (data.redirect_url) {
            window.location.href = data.redirect_url;
          }
          else {
            const frame = document.getElementById(data.turbo_frame);
            frame.innerHTML = data.html;
          }
        },
      }
    );
  }

  disconnect() {
    this.subscription.unsubscribe();
  }
}
