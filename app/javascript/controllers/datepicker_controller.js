import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
export default class extends Controller {
  static targets = ["startDate", "endDate"]; // Liens vers les champs masqués

  connect() {
    console.log("hello")
    // Initialisation de Flatpickr (ou un autre sélecteur de date)
    this.initializeDatepicker();
  }

  initializeDatepicker() {
    flatpickr(this.element, {
      mode: "range",
      dateFormat: "Y-m-d",
      inline: true,
      altFormat: "D/M/Y",
      onChange: this.updateFields.bind(this),
    });
  }

  updateFields(selectedDates) {
    if (selectedDates.length === 2) {
      const [start, end] = selectedDates; // Extraire les dates de début et de fin
      document.getElementById("start-date").value = this.formatDate(start);
      document.getElementById("end-date").value = this.formatDate(end);
    }
  }

  formatDate(date) {
    // Formater la date en "YYYY-MM-DD"
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }
}
