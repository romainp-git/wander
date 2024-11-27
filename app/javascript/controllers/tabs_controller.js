import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "content", "day"];

  connect() {
    // Active automatiquement le premier jour au chargement
    this.activateDay(0);
  }

  changeTab(event) {
    // Récupère l'index du jour cible à partir de `data-tabs-day`
    const targetIndex = parseInt(event.currentTarget.dataset.tabsDay, 10);
    this.activateDay(targetIndex);
  }

  activateDay(index) {
    // Activer l'onglet correspondant
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("tab-active", i === index);
      tab.classList.toggle("text-white", i === index);
      tab.classList.toggle("border-white", i === index);
      tab.classList.toggle("text-gray-400", i !== index);
    });

    // Afficher uniquement le contenu de l'onglet/jour actif
    this.contentTargets.forEach((content) => {
      content.classList.toggle("hidden", parseInt(content.dataset.tabsDay, 10) !== index);
    });

    // Mettre à jour la sélection dans le calendrier
    this.dayTargets.forEach((day, i) => {
      day.classList.toggle("text-black", i === index);
      day.classList.toggle("bg-white", i === index);
      day.classList.toggle("rounded-lg", i === index);
      day.classList.toggle("px-2", i === index);
      day.classList.toggle("py-1", i === index);
      day.classList.toggle("text-gray-400", i !== index);
    });
  }
}
