import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["day", "timeline", "timelineDay", "tab", "tabActivity", "content", "tabsContainer", "daysContainer", "hiddenDate"];
  static values = { defaultColor: { type: String, default: "white" }};

  connect() {
    console.log("Tabs controller connected");
    this.activateDay(0, this.defaultColorValue);
    this.isScrolling = false;
    this.hiddenDateTarget.value = this.dayTargets[0].dataset.date

    window.addEventListener("scroll", this.onScroll.bind(this));
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll.bind(this));
  }

  changeTab(event, color) {
    const targetIndex = parseInt(event.currentTarget.dataset.tabsDay, 10);

    if (!this.isScrolling) {
      this.isScrolling = true;
      this.activateDay(targetIndex, color);
      this.scrollToTimelineDay(targetIndex, () => {
        this.isScrolling = false;
      });
    }
  }

  activateDay(index, color = this.defaultColorValue) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("tab-active", i === index);
      tab.classList.toggle("text-white", i === index);
      tab.classList.toggle("!border-white", i === index);
      tab.classList.toggle("!border-gray-600", i !== index);
      tab.classList.toggle("text-gray-400", i !== index);
    });

    this.dayTargets.forEach((dayTab, i) => {
      dayTab.classList.toggle("text-black", i === index);
      dayTab.classList.toggle(`bg-${color}`, i === index);
      dayTab.classList.toggle("rounded-lg", i === index);
      dayTab.classList.toggle("px-2", i === index);
      dayTab.classList.toggle("py-1", i === index);
      dayTab.classList.toggle("text-gray-400", i !== index);
    });
  }

  scrollToTab(index) {
    const targetTab = this.tabTargets[index];
    if (targetTab) {
      this.tabsContainerTarget.scrollTo({
        left: targetTab.offsetLeft,
        behavior: "smooth",
      });
    }

    const targetDay = this.dayTargets[index];
    if (targetDay) {
      this.daysContainerTarget.scrollTo({
        left: targetDay.offsetLeft,
        behavior: "smooth",
      });
    }
  }

  switchTab(event) {
    const tabName = event.currentTarget.dataset.tabName;
    this.activateTabByName(tabName);
  }

  activateTab(index) {
    this.tabActivityTargets.forEach((tab, i) => {
      tab.classList.toggle("tab-active", i === index);
    });
    this.contentTargets.forEach((content, i) => {
      content.classList.toggle("hidden", i !== index);
    });
  }

  activateTabByName(name) {
    this.tabActivityTargets.forEach((tab) => {
      const isActive = tab.dataset.tabName === name;
      tab.classList.toggle("tab-active", isActive);
      tab.classList.toggle("text-white", isActive);
      tab.classList.toggle("!border-white", isActive);

    });
    this.contentTargets.forEach((content) => {
      const isActive = content.dataset.tabName === name;
      content.classList.toggle("hidden", !isActive);
    });
  }

  scrollToTimelineDay(index, callback) {
    const targetDay = this.timelineDayTargets[index];

    if (targetDay) {
      window.scrollTo({
        top: targetDay.offsetTop,
        behavior: "smooth",
      });
      setTimeout(callback, 500);
    } else {
      callback();
    }
  }

  onScroll() {
    if (this.isScrolling) return;

    const scrollPosition = window.scrollY;
    const bottomPosition = document.documentElement.scrollHeight - window.innerHeight;

    let activeIndex = 0;

    if (scrollPosition >= bottomPosition - 1) {
      activeIndex = this.timelineDayTargets.length - 1;
    } else {
      this.timelineDayTargets.forEach((day, index) => {
        const dayOffset = day.offsetTop;
        const nextDayOffset = index + 1 < this.timelineDayTargets.length
          ? this.timelineDayTargets[index + 1].offsetTop
          : Infinity;

        if (scrollPosition >= dayOffset - 50 && scrollPosition < nextDayOffset - 50) {
          activeIndex = index;
        }
      });
    }

    this.activateDay(activeIndex);
    this.scrollToTab(activeIndex);
  }
  updateDate(event) {
    this.changeTab(event, "orange-500")
    const selectedDayIndex = parseInt(event.currentTarget.dataset.tabsDay, 10);

    // Vérifiez que l'index sélectionné est valide
    const days = this.element.querySelectorAll("[data-tabs-day]");

    const selectedDayElement = days[selectedDayIndex];
    const dateAttribute = selectedDayElement.dataset.date;

    if (!dateAttribute) {
      console.error("Attribut data-date manquant pour le jour sélectionné.");
      return;
    }

    if (!this.hasHiddenDateTarget) {
      console.error("Le champ hiddenDate n'a pas été trouvé.");
      return;
    }

    // Mettez à jour la valeur du champ caché
    this.hiddenDateTarget.value = dateAttribute;
    console.log("Date mise à jour :", dateAttribute);
  }
}
