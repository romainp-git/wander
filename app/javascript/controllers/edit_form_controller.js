import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

    connect() {

    }

    display(event) {

      const form = event.target.closest('[data-edit-target="form"]')
      form.querySelector('.old-value').classList.toggle('hidden');
      form.querySelector('.new-value').classList.toggle('hidden');

  }
}
