/* searchform.js */

function addOnSubmitHandler() {
  const form = document.querySelector("form.search-query-form");
  if (form && !(form.dataset.configured == 'true')) {
    form.dataset.configured = 'true';
    form.addEventListener("submit", (event) => {
      // Your submit handler logic here
      const withinCollectionSelect = form.querySelector("#within_collection");
      if (withinCollectionSelect.name === "f[collection][]") {
        form.querySelector("input[name='group']").remove();
      }
    });
  }
}

document.addEventListener("turbo:load", addOnSubmitHandler);

if (document.readyState !== "loading") {
  addOnSubmitHandler();
} else {
  document.addEventListener("DOMContentLoaded", addOnSubmitHandler);
}


document.addEventListener("turbo:render", () => {
  addOnSubmitHandler();
});

document.addEventListener("turbo:frame-load", (event) => {
  addOnSubmitHandler();
});
