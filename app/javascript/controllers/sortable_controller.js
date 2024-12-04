import Controller from "@stimulus-components/sortable";

export default class extends Controller {
  connect() {
    super.connect();

    console.log("Sortable connected for group:", this.element.dataset.sortableGroup);
  }

  get defaultOptions() {
    return {
      group: {
        name: "shared",
        pull: true,
        put: true,
      },
      animation: 150,
      handle: ".handle",
      onEnd: (event) => this.onEnd(event),
    };
  }

  onEnd(event) {
    const item = event.item;
    const newIndex = event.newIndex;
    const oldIndex = event.oldIndex;
    const fromGroup = event.from.dataset.sortableGroup;
    const toGroup = event.to.dataset.sortableGroup;
    const updateUrl = item.dataset.sortableUpdateUrl;

    console.log("Movement detected:", { fromGroup, toGroup, newIndex, oldIndex });

    if (!updateUrl) {
      console.error("No update URL found for item:", item);
      return;
    }

    const data = {
      trip_activity: {
        new_group: toGroup,
        position: newIndex,
      },
    };

    console.log("Sending data:", data);


    fetch(updateUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify(data),
    })
      .then((response) => {
        if (response.ok) {
          console.log("Activity reordered successfully!");
        } else {
          console.error("Failed to reorder activity", response);
        }
      })
      .catch((error) => console.error("Error:", error));
  }
}
