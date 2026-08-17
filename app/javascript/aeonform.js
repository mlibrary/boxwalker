/* aeonform.js */

const CHECKBOX_SELECTOR = 'input[type="checkbox"][name="Request"]';
const FORM_ID = "EADRequestFormId";
const FALLBACK_BUCKET = "null-collection";

const state = {
    collectionId: null,
    selected: new Set(),
    items: new Map(),
};

const storageKeys = () => ({
    selected: `${state.collectionId}_selectedItems`,
    items: `${state.collectionId}_collectionItems`,
});

function collectionIdFromIdentifier(identifier) {
    const idx = identifier?.indexOf("_aspace_") ?? -1;
    return idx > 0 ? identifier.slice(0, idx) : null;
}

function currentCollectionId() {
    const idno = document.querySelector(`#${FORM_ID} input[name="idno"]`)?.value;
    if (idno) return idno;

    const checkbox = document.querySelector(CHECKBOX_SELECTOR);
    const fromCheckbox = checkbox && collectionIdFromIdentifier(checkbox.value);
    if (fromCheckbox) return fromCheckbox;

    const doc = document.querySelector("[data-document-id]");
    const fromDoc = doc && collectionIdFromIdentifier(doc.dataset.documentId);
    if (fromDoc) return fromDoc;

    if (checkbox) {
        console.warn(
            "aeonform: Request checkboxes present but no collection could be resolved; " +
            "using shared fallback bucket."
        );
    }
    return FALLBACK_BUCKET;
}

function assertSingleCollection() {
    const ids = new Set(
        [...document.querySelectorAll(CHECKBOX_SELECTOR)]
            .map((cb) => collectionIdFromIdentifier(cb.value))
            .filter(Boolean)
    );
    if (ids.size > 1) {
        console.warn("aeonform: page mixes collections:", [...ids]);
    }
}

function readJSON(key, fallback) {
    try {
        return JSON.parse(sessionStorage.getItem(key)) ?? fallback;
    } catch {
        return fallback;
    }
}

function loadState() {
    state.collectionId = currentCollectionId();
    const keys = storageKeys();
    state.selected = new Set(readJSON(keys.selected, []));
    state.items = new Map(Object.entries(readJSON(keys.items, {})));
}

let warnedPersistenceFailure = false;
function saveState() {
    const keys = storageKeys();
    try {
        sessionStorage.setItem(keys.selected, JSON.stringify([...state.selected]));
        sessionStorage.setItem(keys.items, JSON.stringify(Object.fromEntries(state.items)));
    } catch {
        // Continue with in-memory state when session storage is unavailable.
        if (!warnedPersistenceFailure) {
            warnedPersistenceFailure = true;
            console.warn("aeonform: sessionStorage write failed; selections won't persist across navigation.");
        }
    }
}

function ensureCurrentCollection() {
    if (state.collectionId !== currentCollectionId()) {
        loadState();
        restoreCheckboxes();
        updateCount();
    }
}

function harvestItemMetadata() {
    let dirty = false;

    document.querySelectorAll(CHECKBOX_SELECTOR).forEach((checkbox) => {
        const identifier = checkbox.value;
        if (state.items.has(identifier)) return;

        const suffix = `_${identifier}`;
        const metadata = {};
        checkbox.closest("label")?.querySelectorAll("input").forEach((input) => {
            if (input.name && input.name.endsWith(suffix)) {
                metadata[input.name] = input.value;
            }
        });

        state.items.set(identifier, metadata);
        dirty = true;
    });

    if (dirty) saveState();
}

function updateCount() {
    const span = document.getElementById("selected-items-count");
    if (!span) return;

    const count = state.selected.size;
    span.innerHTML = count > 0
        ? `<span>${count}</span>` + `<span class="visually-hidden">Request ${count} ${count === 1 ? "item" : "items"}</span>`
        : ""
}

function restoreCheckboxes(root = document) {
    root.querySelectorAll(CHECKBOX_SELECTOR).forEach((checkbox) => {
        checkbox.checked = state.selected.has(checkbox.value);
    });
}

function clearAll() {
    document.querySelectorAll(CHECKBOX_SELECTOR).forEach((cb) => { cb.checked = false; });
    state.selected.clear();
    state.items.clear();
    saveState();
    updateCount();
}

function hiddenInput(name, value) {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = name;
    input.value = value;
    return input;
}

function submitAeonRequest(sourceForm) {
    ensureCurrentCollection();

    if (state.selected.size === 0) {
        alert(
            "Please select one or more items to request.\n" +
            "(You may need to scroll down to see the checkboxes)"
        );
        return;
    }

    document.querySelectorAll(".aeon-submitted-form").forEach((f) => f.remove());

    const form = sourceForm.cloneNode(true);
    form.id = `${FORM_ID}-${Date.now()}`;
    form.classList.add("aeon-submitted-form");
    form.hidden = true;
    form.querySelectorAll("[id]").forEach((el) => el.removeAttribute("id"));

    // Avoids duplicate/stale request values).
    form.querySelectorAll('input[name="Request"]').forEach((el) => el.remove());

    state.selected.forEach((identifier) => {
        form.append(hiddenInput("Request", identifier));
        Object.entries(state.items.get(identifier) ?? {}).forEach(([name, value]) => {
            form.append(hiddenInput(name, value));
        });
    });

    document.body.append(form);
    form.submit();
    clearAll();
}

document.addEventListener("change", (event) => {
    const checkbox = event.target.closest?.(CHECKBOX_SELECTOR);
    if (!checkbox) return;

    ensureCurrentCollection();
    harvestItemMetadata();

    if (checkbox.checked) {
        state.selected.add(checkbox.value);
    } else {
        state.selected.delete(checkbox.value);
    }

    saveState();
    updateCount();
});

document.addEventListener("submit", (event) => {
    const form = event.target;
    if (form.id !== FORM_ID) return;

    event.preventDefault();
    submitAeonRequest(form);
});

document.addEventListener("click", (event) => {
    if (event.target.closest("[data-aeon-submit]")) {
        event.preventDefault();
        document.getElementById(FORM_ID)?.requestSubmit();
        return;
    }
    if (event.target.closest("[data-aeon-clear]")) {
        event.preventDefault();
        clearAll();
    }
});

function initialize() {
    loadState();
    assertSingleCollection();
    harvestItemMetadata();
    restoreCheckboxes();
    updateCount();
}

document.addEventListener("turbo:load", initialize);

if (document.readyState !== "loading") {
    initialize();
} else {
    document.addEventListener("DOMContentLoaded", initialize);
}

document.addEventListener("turbo:render", () => {
    ensureCurrentCollection();
    restoreCheckboxes();
    updateCount();
});

document.addEventListener("turbo:before-cache", () => {
    const span = document.getElementById("selected-items-count");
    if (span) span.innerHTML = "";
    document.querySelectorAll(CHECKBOX_SELECTOR).forEach((cb) => { cb.checked = false; });
});

document.addEventListener("turbo:frame-load", (event) => {
    ensureCurrentCollection();
    harvestItemMetadata();
    restoreCheckboxes(event.target);
    updateCount();
});
