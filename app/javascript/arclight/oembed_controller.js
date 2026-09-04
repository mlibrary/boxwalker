import { Controller } from '@hotwired/stimulus'

const PARTNER_ID = '1758271'
const UICONF_ID = '56928822'
const PLAYER_HOST = 'https://cdnapisec.kaltura.com'
const ENTRY_ID_PATTERN = /^\d_[a-z0-9]{8}$/i

// Kaltura-backed hosts (kaltura.com and MediaSpace instances)
const KALTURA_HOST_SUFFIXES = ['.kaltura.com', '.mivideo.it.umich.edu']

export default class OembedController extends Controller {
     static values = {
          url: String
     }

     connect() {
          if (this.element.getAttribute('loaded') === 'loaded') return

          const entryId = this.findKalturaEntryId()
          if (entryId) {
               this.loadKalturaEmbed(entryId)
               return
          }

          this.loadOEmbed()
     }

     findKalturaEntryId() {
          let url

          try {
               url = new URL(this.urlValue, window.location.href)
          } catch (error) {
               console.warn(`Invalid oEmbed URL: ${this.urlValue}`, error)
               return null
          }

          const isKalturaHost = url.hostname === 'kaltura.com'
              || KALTURA_HOST_SUFFIXES.some((suffix) => url.hostname.endsWith(suffix))
          if (!isKalturaHost) return null

          const queryEntryId = url.searchParams.get('entry_id')
          if (queryEntryId && ENTRY_ID_PATTERN.test(queryEntryId)) {
               return queryEntryId
          }

          return url.pathname
              .match(/(?:^|\/)(\d_[a-z0-9]{8})(?:\/|$)/i)?.[1] || null
     }

     loadKalturaEmbed(entryId) {
          const linkContainer = this.element.querySelector('.al-digital-object')
          if (!linkContainer) {
               console.warn('Could not find .al-digital-object for Kaltura embed')
               return
          }

          const params = new URLSearchParams({
               iframeembed: 'true',
               entry_id: entryId
          })

          const iframe = document.createElement('iframe')
          iframe.src = `${PLAYER_HOST}/p/${PARTNER_ID}/embedPlaykitJs/uiconf_id/${UICONF_ID}?${params}`
          iframe.setAttribute('allowfullscreen', '')
          iframe.setAttribute('allow', 'autoplay; fullscreen; encrypted-media')
          iframe.setAttribute(
              'title',
              this.element.querySelector('a')?.textContent?.trim() || 'Media player'
          )
          iframe.style.cssText = 'width: 100%; aspect-ratio: 16 / 9; height: auto; border: 0;'

          // Keep the original link as a fallback.
          linkContainer.insertAdjacentElement('beforebegin', iframe)
          this.element.setAttribute('loaded', 'loaded')
     }

     loadOEmbed() {
          fetch(this.urlValue)
              .then((response) => {
                   if (response.ok) return response.text()
                   throw new Error(`HTTP error, status = ${response.status}`)
              })
              .then((body) => {
                   const endpoint = this.findOEmbedEndpoint(body)
                   if (!endpoint) {
                        console.warn(`No oEmbed endpoint found in <head> at ${this.urlValue}`)
                        return null
                   }

                   return fetch(endpoint)
              })
              .then((response) => {
                   if (!response) return null
                   if (response.ok) return response.json()
                   throw new Error(`HTTP error, status = ${response.status}`)
              })
              .then((json) => {
                   if (!json?.html) return

                   this.element.innerHTML = json.html
                   this.element.setAttribute('loaded', 'loaded')
              })
              .catch((error) => {
                   console.error(error)
              })
     }

     findOEmbedEndpoint(body) {
          const doc = new DOMParser().parseFromString(body, 'text/html')
          const endpoint = doc
              .querySelector('link[rel="alternate"][type="application/json+oembed"]')
              ?.getAttribute('href')

          if (!endpoint) return null

          return new URL(endpoint, this.urlValue).toString()
     }
}