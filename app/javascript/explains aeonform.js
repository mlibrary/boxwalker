This script manages a shopping-cart-like selection of archival items (via checkboxes) for an Aeon request form, persisting selections in sessionStorage across page navigations (including Turbo navigation). Here's what each chunk does:

Constants & State
const CHECKBOX_SELECTOR ...
const FORM_ID ...
const FALLBACK_BUCKET ...

Defines the CSS selector for request checkboxes, the request form's ID, and a fallback storage key used when no collection can be identified.

const state = { collectionId, selected, items }

In-memory state: the current collection's ID, a Set of selected item identifiers, and a Map of item metadata.

const storageKeys = () => ...

Generates namespaced sessionStorage keys (scoped per collection) for saving selections and item metadata.

Collection Identification
function collectionIdFromIdentifier(identifier)

Extracts the collection ID from an item identifier by taking everything before the _aspace_ marker.

function currentCollectionId()

Determines the current collection ID by checking (in order): a DOM element's data-ead-id, a checkbox value, then a data-document-id. Falls back to the shared bucket (with a warning) if none work.

function assertSingleCollection()

Sanity check: warns to the console if the page contains checkboxes from more than one collection.

Persistence
function readJSON(key, fallback)

Safely reads and parses JSON from sessionStorage, returning a fallback on error/missing data.

function loadState()

Loads state from sessionStorage: sets collection ID, restores the selected set and items map.

function saveState()

Serializes and writes the current selected set and items map back to sessionStorage.

function ensureCurrentCollection()

Detects if the collection has changed (e.g. after navigation); if so, reloads state and refreshes the UI.

Metadata & UI
function harvestItemMetadata()

For each checkbox not already recorded, scrapes associated hidden <input> fields (matching the item's suffix) within its label to capture item metadata, then saves if anything changed.

function updateCount()

Updates the "selected items count" badge, with accessible (screen-reader) text, or clears it when zero.

function restoreCheckboxes(root = document)

Re-checks any checkboxes whose identifiers are in the selected set (used after page/frame loads).

function clearAll()

Unchecks all checkboxes, clears the selection and items state, saves, and updates the count.

function hiddenInput(name, value)

Helper that creates a hidden <input> element with a given name/value.

Form Submission
function submitAeonRequest(sourceForm)

Handles submitting the request: validates that something is selected (alerts if not), clones the source form, strips IDs, injects hidden inputs for each selected item plus its metadata, appends it to the body, submits it, then clears everything.

Event Listeners
document.addEventListener("change", ...)

When a request checkbox toggles, harvests metadata and adds/removes the item from the selection, then saves and updates the count.

document.addEventListener("submit", ...)

Intercepts submission of the target form, preventing default and routing to submitAeonRequest.

document.addEventListener("click", ...)

Handles custom triggers: [data-aeon-submit] programmatically submits the form; [data-aeon-clear] clears all selections.

Initialization & Turbo Hooks
function initialize()

Bootstraps everything: loads state, checks for mixed collections, harvests metadata, restores checkboxes, updates count.

turbo:load / readyState / DOMContentLoaded

Runs initialize on both standard page load and Turbo navigation (handling whichever fires).

turbo:render

After a Turbo render, re-syncs collection, checkboxes, and count.

turbo:before-cache

Before Turbo caches a page snapshot, clears the count badge and unchecks boxes so cached pages don't show stale UI state.

turbo:frame-load

When a Turbo Frame loads new content, refreshes collection state, harvests metadata, and restores checkboxes within the newly loaded frame.