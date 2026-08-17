/**
 * aeonform.js
 *
 * Manages a cart-like selection of archival items (checkboxes) for an Aeon
 * request form, persisting selections across (Turbo) navigation.
 *
 * ── STABILITY CONTRACT ──────────────────────────────────────────────────────
 * This feature depends on two things staying stable. Changing either without
 * updating this file will silently break selection persistence and/or grouping:
 *
 *   1. sessionStorage
 *      Selections and harvested item metadata are stored in sessionStorage,
 *      keyed per collection (see `storageKeys`). If storage is unavailable,
 *      cleared, or the key format changes, previously selected items will not
 *      be restored. State is intentionally session-scoped: it does NOT survive
 *      a new browser session, and that is by design.
 *
 *   2. Identifier parsing (the "_aspace_" marker)
 *      Every item identifier (checkbox `value`) is assumed to have the form
 *      "<collectionId>_aspace_<...>". `collectionIdFromIdentifier` derives the
 *      collection ID from the substring before "_aspace_", which in turn
 *      namespaces the storage keys.
 * ────────────────────────────────────────────────────────────────────────────
 */

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
    const el = document.getElementById("eadid") ?? document.querySelector("[data-ead-id]");
    if (el?.dataset.eadId) return el.dataset.eadId;

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

function saveState() {
    const keys = storageKeys();
    sessionStorage.setItem(keys.selected, JSON.stringify([...state.selected]));
    sessionStorage.setItem(keys.items, JSON.stringify(Object.fromEntries(state.items)));
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

// Two-way restoration: every checkbox is set to reflect the authoritative
// selection state — checked if selected, unchecked otherwise. This prevents
// stale `checked` markup (server-rendered or bfcache-restored) from lingering.
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
