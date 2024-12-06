import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "uploadContainer", "previewContainer"];

  connect() {
    console.log("File upload controller connected");
  }

  inputChange(event) {
    const fileInput = this.inputTarget;
    const previewContainer = this.previewContainerTarget;
    const uploadContainer = this.uploadContainerTarget;

    // Limite à 3 fichiers
    if (fileInput.files.length > 3) {
      alert("Vous ne pouvez sélectionner que 3 photos maximum.");
      fileInput.value = ""; // Réinitialise la sélection
      return;
    }

    // Effacez les vignettes précédentes
    previewContainer.innerHTML = "";

    if (fileInput.files.length > 0) {
      // Affiche les vignettes
      Array.from(fileInput.files).forEach((file, index) => {
        if (file.type.startsWith("image/")) {
          const reader = new FileReader();

          // Lors du chargement de l'image
          reader.onload = (e) => {
            const img = document.createElement("img");
            img.src = e.target.result;
            img.alt = file.name;
            img.classList.add("w-24", "h-24", "object-cover", "rounded-md", "shadow-md", "border", "border-gray-600");

            const div = document.createElement("div");
            div.classList.add("relative");

            // Ajout d'un bouton de suppression (optionnel)
            const removeButton = document.createElement("button");
            removeButton.innerHTML = "×";
            removeButton.classList.add(
              "absolute", "top-0", "right-0",
              "w-6", "h-6", "bg-red-500", "text-white", "rounded-full",
              "text-sm", "flex", "items-center", "justify-center",
              "hover:bg-red-600", "focus:outline-none"
            );
            removeButton.onclick = () => {
              this.removeFile(index);
              div.remove();

              // Si toutes les images sont supprimées, réaffichez l'interface d'upload
              if (this.inputTarget.files.length === 0) {
                this.resetUpload();
              }
            };

            div.appendChild(img);
            div.appendChild(removeButton);
            previewContainer.appendChild(div);
          };

          // Lecture de l'image
          reader.readAsDataURL(file);
        }
      });

      // Masquez l'interface d'upload et affichez les vignettes
      uploadContainer.classList.add("hidden");
      previewContainer.classList.remove("hidden");
    }
  }

  removeFile(index) {
    const files = Array.from(this.inputTarget.files);
    files.splice(index, 1);

    const dataTransfer = new DataTransfer();
    files.forEach((file) => dataTransfer.items.add(file));
    this.inputTarget.files = dataTransfer.files;
  }

  resetUpload() {
    const previewContainer = this.previewContainerTarget;
    const uploadContainer = this.uploadContainerTarget;

    // Réinitialisez le champ input et les vignettes
    this.inputTarget.value = "";
    previewContainer.innerHTML = "";
    previewContainer.classList.add("hidden");
    uploadContainer.classList.remove("hidden");
  }
}
