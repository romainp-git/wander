// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

document.querySelectorAll('.day-tab').forEach(tab => {
  tab.addEventListener('click', () => {
    const selectedDay = tab.dataset.day;

    // Mettre à jour les onglets actifs
    document.querySelectorAll('.day-tab').forEach(t => {
      t.classList.remove('font-medium', 'border-b-2', 'border-gray-800', 'text-gray-600');
      t.classList.add('text-gray-400');
    });
    tab.classList.add('font-medium', 'border-b-2', 'border-gray-800', 'text-gray-600');

    // Afficher les activités du jour sélectionné
    document.querySelectorAll('.day-content').forEach(content => {
      if (content.dataset.day === selectedDay) {
        content.classList.remove('hidden');
      } else {
        content.classList.add('hidden');
      }
    });
  });
});
