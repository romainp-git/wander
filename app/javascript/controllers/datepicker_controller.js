import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="datepicker"
export default class extends Controller {
  static targets = ["startDate", "endDate", "calendar"]; // Liens vers les champs masqués

  connect() {
    console.log("flatpicker_controller")
    this.initializeDatepicker();
  }

  initializeDatepicker() {
    flatpickr(this.element, {
      minDate: "today",
      appendTo: this.calendarTarget,
      mode: "range",
      dateFormat: "Y-m-d",
      locale: {
        firstDayOfWeek: 1,
        weekdays: {
          shorthand: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
          longhand: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
        },
        months: {
          shorthand: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'],
          longhand: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
        },
      },
      inline: true,
      altFormat: "D/M/Y",
      onChange: this.updateFields.bind(this),
    });

    flatpickr.localize(flatpickr.l10ns.fr);
  }

  updateFields(selectedDates) {
    if (selectedDates.length === 2) {
      const [start, end] = selectedDates; // Extraire les dates de début et de fin
      this.startDateTarget.textContent  = this.formatDate(start);
      this.endDateTarget.textContent = this.formatDate(end);
    }
  }

  formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${day}-${month}-${year}`;
  }
}
