import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["day", "timeline", "timelineDay", "tab", "tabActivity", "content", "tabsContainer"];

  connect() {
    console.log("Tabs controller connected");
    this.activateDay(0);
    this.isScrolling = false;

    window.addEventListener("scroll", this.onScroll.bind(this));
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll.bind(this));
  }

  changeTab(event) {
    const targetIndex = parseInt(event.currentTarget.dataset.tabsDay, 10);

    if (!this.isScrolling) {
      this.isScrolling = true;
      this.activateDay(targetIndex);
      this.scrollToTimelineDay(targetIndex, () => {
        this.isScrolling = false;
      });
    }
  }

  activateDay(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("tab-active", i === index);
      tab.classList.toggle("text-white", i === index);
      tab.classList.toggle("!border-white", i === index);
      tab.classList.toggle("!border-gray-600", i !== index);
      tab.classList.toggle("text-gray-400", i !== index);
    });

    this.dayTargets.forEach((dayTab, i) => {
      dayTab.classList.toggle("text-black", i === index);
      dayTab.classList.toggle("bg-white", i === index);
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
}
