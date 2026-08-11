// aeonform.js — Aeon request support for ArcLight
(() => {
    "use strict";

    const CHECKBOX_SELECTOR = 'input[type="checkbox"][name="Request"]';
    const FORM_ID = "EADRequestFormId";

    //--------------------------------------------------------------------
    // Per-collection state, persisted in sessionStorage
    // (storage keys are unchanged, so existing sessions keep working)

    const state = {
        collectionId: null,
        selected: new Set(), // identifiers the user has checked
        items: new Map(),    // identifier -> { hiddenFieldName: value, ... }
    };

    const storageKeys = () => ({
        selected: `${state.collectionId}_selectedItems`,
        items: `${state.collectionId}_collectionItems`,
    });

    const currentCollectionId = () =>
        document.getElementById("eadid")?.dataset.eadId ?? "null-collection";

    function loadState() {
        state.collectionId = currentCollectionId();
        const keys = storageKeys();
        state.selected = new Set(JSON.parse(sessionStorage.getItem(keys.selected)) ?? []);
        state.items = new Map(
            Object.entries(JSON.parse(sessionStorage.getItem(keys.items)) ?? {})
        );
    }

    function saveState() {
        const keys = storageKeys();
        sessionStorage.setItem(keys.selected, JSON.stringify([...state.selected]));
        sessionStorage.setItem(keys.items, JSON.stringify(Object.fromEntries(state.items)));
    }

    //--------------------------------------------------------------------
    // Metadata harvesting: capture each checkbox's sibling hidden inputs
    // so items remain requestable after their page of results is gone

    function harvestItemMetadata() {
        let dirty = false;

        document.querySelectorAll(CHECKBOX_SELECTOR).forEach((checkbox) => {
            const identifier = checkbox.value;
            if (state.items.has(identifier)) return;

            const metadata = {};
            checkbox.closest("label")?.querySelectorAll("input").forEach((input) => {
                if (input.name && input.name.includes(identifier)) {
                    metadata[input.name] = input.value;
                }
            });

            state.items.set(identifier, metadata);
            dirty = true;
        });

        if (dirty) saveState();
    }

    //--------------------------------------------------------------------
    // UI

    function updateCount() {
        const span = document.getElementById("selected-items-count");
        if (!span) return;

        const count = state.selected.size;
        span.innerHTML = count === 0
            ? ""
            : `<span class="visually-hidden">Request </span>${count}` +
            `<span class="visually-hidden"> ${count === 1 ? "item" : "items"}</span>`;
    }

    function restoreCheckboxes(root = document) {
        state.selected.forEach((identifier) => {
            const checkbox = root.querySelector(
                `${CHECKBOX_SELECTOR}[value="${CSS.escape(identifier)}"]`
            );
            if (checkbox) checkbox.checked = true;
        });
    }

    function clearAll() {
        document.querySelectorAll(CHECKBOX_SELECTOR).forEach((cb) => { cb.checked = false; });
        state.selected.clear();
        state.items.clear();
        saveState();
        updateCount();
    }

    //--------------------------------------------------------------------
    // Aeon submission

    function hiddenInput(name, value) {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = name;
        input.value = value;
        return input;
    }

    function submitAeonRequest(sourceForm) {
        if (state.selected.size === 0) {
            alert(
                "Please select one or more items to request.\n" +
                "(You may need to scroll down to see the checkboxes)"
            );
            return;
        }

        // remove any forms left over from a previous submission
        document.querySelectorAll(".aeon-submitted-form").forEach((f) => f.remove());

        const form = sourceForm.cloneNode(true);
        form.id = `${FORM_ID}-${Date.now()}`;
        form.classList.add("aeon-submitted-form");
        form.hidden = true;

        state.selected.forEach((identifier) => {
            form.append(hiddenInput("Request", identifier));
            Object.entries(state.items.get(identifier) ?? {}).forEach(([name, value]) => {
                form.append(hiddenInput(name, value));
            });
        });

        document.body.append(form);
        form.submit(); // programmatic submit() does NOT re-fire the submit event
        clearAll();
    }

    //--------------------------------------------------------------------
    // Event delegation — bound once, survives Turbo Drive/Frame/Stream updates

    document.addEventListener("change", (event) => {
        const checkbox = event.target.closest?.(CHECKBOX_SELECTOR);
        if (!checkbox) return;

        harvestItemMetadata(); // covers checkboxes that arrived after page load

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
        const trigger = event.target.closest("[data-aeon-submit]");
        if (!trigger) return;
        event.preventDefault();
        document.getElementById(FORM_ID)?.requestSubmit();
    });


    document.addEventListener("click", (event) => {
        if (!event.target.closest("[data-aeon-clear]")) return;
        clearAll();
    });

    //--------------------------------------------------------------------
    // Turbo lifecycle

    document.addEventListener("turbo:load", () => {
        loadState();            // re-keys state when the user switches collections
        harvestItemMetadata();
        restoreCheckboxes();
        updateCount();
    });

    // ArcLight loads contents/pagination inside turbo-frames;
    // this replaces the old jQuery 'navigation.contains.elements' event
    document.addEventListener("turbo:frame-load", (event) => {
        harvestItemMetadata();
        restoreCheckboxes(event.target);
    });

    //--------------------------------------------------------------------
    // Back-compat shim for markup using onclick="return SubmitAeonRequestForm()"
    // requestSubmit() (unlike submit()) fires the submit event, so it flows
    // through the delegated handler above.

    window.SubmitAeonRequestForm = () => {
        document.getElementById(FORM_ID)?.requestSubmit();
        return false;
    };
})();