import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "content", "day","tabActivity"];

  connect() {
    console.log("tabs controller connected");
    this.activateDay(0);
    this.activateTab(0);
  }

  changeTab(event) {
    const targetIndex = parseInt(event.currentTarget.dataset.tabsDay, 10);
    this.activateDay(targetIndex);
  }

  activateDay(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("tab-active", i === index);
      tab.classList.toggle("text-white", i === index);
      tab.classList.toggle("border-white", i === index);
      tab.classList.toggle("text-gray-400", i !== index);

      if (i === index) {
        this.scrollIntoView(tab);
      }
    });
    this.contentTargets.forEach((content) => {
      content.classList.toggle("hidden", parseInt(content.dataset.tabsDay, 10) !== index);
    });

    this.dayTargets.forEach((day, i) => {
      day.classList.toggle("text-black", i === index);
      day.classList.toggle("bg-white", i === index);
      day.classList.toggle("rounded-lg", i === index);
      day.classList.toggle("px-2", i === index);
      day.classList.toggle("py-1", i === index);
      day.classList.toggle("text-gray-400", i !== index);

      if (i === index) {
        this.scrollIntoView(day);
      }
    });
  }

  scrollIntoView(element) {
    element.scrollIntoView({
      behavior: "smooth",
      block: "nearest",
      inline: "center",
    });
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
}
