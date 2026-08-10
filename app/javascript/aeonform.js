// aeonform.js supports aeon requests

//----------------------------------------------------------------------
// Utility functions

function sessionSave(key, value) {
    if ( value == null ) {
        sessionStorage.removeItem(key);
    } else {
        if ( value instanceof Map ) { value = Object.fromEntries(value); }
        else { value = Array.from(value); }
        sessionStorage.setItem(key, JSON.stringify(value));
    }
}

function ClearAllCheckboxes() {
    $(':checkbox').prop('checked', false);
    collectionItems().clear();
    saveCollectionItems();
    selectedItems().clear();
    saveSelectedItems();
    updateSelectedItemsCount();
}

function _RestoreSelectedCheckboxes() {
    selectedItems().forEach((identifier) => {
        let $inputEl = $(`input[name="Request"][value="${identifier}"]`);
        $inputEl.prop('checked', true);
        console.log("-- NAVIGATION al-contents", identifier, $inputEl.get(0));
    });
}

//----------------------------------------------------------------------
// Submit handler

function SubmitAeonRequestForm() {
    if (selectedItems().size == 0) {
        msg = `Please select one or more items to request.
(You may need to scroll down to see the checkboxes)`;
        alert(msg);
        return false;
    }

    // clean up old forms
    $(".aeon-submitted-form").remove();

    // clone the aeon request form to add the hidden inputs
    let $aeonForm = $("#EADRequestFormId").clone().attr('id', `EADRequestFormId-${(new Date).getTime()}`);
    $aeonForm.css({ display: 'none' }).addClass('aeon-submitted-form');
    selectedItems().forEach((identifier) => {
        let metaData = collectionItems().get(identifier);
        $('<input/>')
            .attr("type", "hidden")
            .attr("name", "Request")
            .attr("value", identifier)
            .appendTo($aeonForm);

        Object.keys(metaData).forEach((key) => {
            $('<input/>')
                .attr("type", "hidden")
                .attr("name", key)
                .attr("value", metaData[key])
                .appendTo($aeonForm);
        })
    })

    $("body").append($aeonForm);
    $aeonForm.submit();

    ClearAllCheckboxes();
    return false;
}

function updateSelectedItemsCount() {
    if ( selectedItems() === undefined ) {
        switchedCollections();
    }
    let $span = $("#selected-items-count");
    if ( selectedItems().size == 0 ) {
        $span.html('');
    } else {
        let description = selectedItems().size == 1 ? 'item' : 'items';
        $span.html(`<span class="sr-only">Request </span>${selectedItems().size}<span class="sr-only"> ${description}</span>`);
    }
}

//----------------------------------------------------------------------
// Document ready set up

let _collectionId;
let _selectedItems;
let _collectionItems;

function collectionId() {
    let $eadEL = $("#eadid");
    if ( $eadEL.length === 0 ) {
        _collectionId = "null-collection";
    } else {
        _collectionId = $eadEL.data("eadId");
    }
    return _collectionId;
}

function selectedItemsKey() {
    return collectionId() + '_selectedItems';
}

function collectionItemsKey() {
    return collectionId() + '_collectionItems';
}

function selectedItems() {
    return _selectedItems;
}

function collectionItems() {
    return _collectionItems;
}

function saveSelectedItems() {
    sessionSave(selectedItemsKey(), _selectedItems);
}

function saveCollectionItems() {
    sessionSave(collectionItemsKey(), _collectionItems);
}

function retrieveSelectedItems() {
    let jsonValue = sessionStorage.getItem(selectedItemsKey());
    if ( jsonValue === null ) {
        _selectedItems = new Set();
        saveSelectedItems();
    } else {
        _selectedItems = new Set(JSON.parse(jsonValue) || []);
    }
}

function retrieveCollectionItems() {
    let jsonValue = sessionStorage.getItem(collectionItemsKey());
    if ( jsonValue === null ) {
        _collectionItems = new Map();
        saveCollectionItems();
    } else {
        _collectionItems = new Map(Object.entries(JSON.parse(jsonValue) || {}));
    }
}

function switchedCollections() {
    retrieveSelectedItems();
    retrieveCollectionItems();
}

// collect the requeset metadata for each identifier
// so it can be submitted even if the checkbox is no longer
// being displayed
function _buildCollectionItemsMap() {
    $('input[type="checkbox"][name="Request"]').each(function (idx, inputEl) {
        let identifier = inputEl.value;
        let datum = {};
        let $labelEl = $(inputEl).parents('label');
        $labelEl.find('input').each(function (i, el) {
            let key = $(el).attr('name');
            if ( key.indexOf(identifier) >= 0 ) {
                let value = $(el).val();
                datum[key] = value;
            }
        })
        collectionItems().set(identifier, datum);
        saveCollectionItems();
    })
}

function _SelectCheckbox() {
    let target = this;
    let identifier = target.value;
    if (!collectionItems().get(identifier)) {
        // either initial page load, or user has loaded
        // another page of checkboxes
        _buildCollectionItemsMap();
    }
    if (target.checked) {
        selectedItems().add(identifier);
    } else {
        selectedItems().delete(identifier);
    }
    saveSelectedItems();

    updateSelectedItemsCount();
}

function _BindEvents() {
    $(`input[type="checkbox"][name="Request"]`).each(function(i, input) {
        if ( input.dataset.initialized ) { return;}
        input.dataset.initialized = true;
        $(input).on('click', _SelectCheckbox);
    });
}

document.addEventListener('turbolinks:load', function(event) {
    // user has switched collections; reset the data structures

    switchedCollections();

    updateSelectedItemsCount();

    _BindEvents();
    _RestoreSelectedCheckboxes();

    // bind checkbox handlers on contents navigation
    $('.al-contents').on('navigation.contains.elements', function() {
        _BindEvents();
    });

    // contents has been paginated; restore any previously made selections
    $('.al-contents').on('navigation.contains.elements', _RestoreSelectedCheckboxes);
});