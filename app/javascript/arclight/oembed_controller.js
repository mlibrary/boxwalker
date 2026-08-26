import { Controller } from '@hotwired/stimulus'

const PARTNER_ID = '1758271'
const UICONF_ID = '56928822'
const PLAYER_HOST = 'https://cdnapisec.kaltura.com'

export default class OembedController extends Controller {
    static values = {
        url: String
    }

    connect() {
        if (this.element.getAttribute('loaded') === 'loaded') return

        const entryId = this.urlValue.match(/(\d_[a-z0-9]{8})/)?.[1]
        if (!entryId) {
            console.warn(`Could not parse Kaltura entry id from ${this.urlValue}`)
            return // leave the original link markup as the fallback
        }

        const iframe = document.createElement('iframe')
        iframe.src = `${PLAYER_HOST}/p/${PARTNER_ID}/embedPlaykitJs/uiconf_id/${UICONF_ID}?iframeembed=true&entry_id=${entryId}`
        iframe.setAttribute('allowfullscreen', '')
        iframe.setAttribute('allow', 'autoplay; fullscreen; encrypted-media')
        iframe.setAttribute('title', this.element.querySelector('a')?.textContent || 'Media player')
        iframe.style.cssText = 'width: 100%; aspect-ratio: 16 / 9; height: auto; border: 0;'

        // Instead of replaceChildren(iframe), append and keep the link:
        this.element.querySelector('.al-digital-object')?.insertAdjacentElement('beforebegin', iframe)
        this.element.setAttribute('loaded', 'loaded')
    }
}
