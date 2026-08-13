import { Controller } from '@hotwired/stimulus'
export default class extends Controller {
    static targets = ['content']
    connect() {
        this._check = this.checkTruncation.bind(this)
        requestAnimationFrame(this._check)
        window.addEventListener('resize', this._check)
    }
    disconnect() {
        window.removeEventListener('resize', this._check)
    }
    checkTruncation() {
        const el = this.contentTarget
        const isTruncated = el.scrollHeight > el.clientHeight + 1
        if (isTruncated) {
            this.element.classList.add('truncated')
        } else {
            this.element.classList.remove('truncated')
            this.element.classList.remove('expanded')
        }
    }
    trigger() {
        this.element.classList.toggle('expanded')
    }
}
