import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ['input', 'suggestions'];

  connect() {
  }

  suggestions() {
    const query = this.inputTarget.value;
    const url = this.element.dataset.suggestionUrl;

    clearTimeout(this.timeout);
    this.timeout = setTimeout(()=> {
      this.requestSuggestions(query, url);
    }, 300)
  }

  requestSuggestions(query, url) {
    if(query.length === 0) {
      this.hideSuggestions();
    } else {
      this.showSuggestions();

      fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({query: query})
      }).then((response) => {
        response.text().then((html) => {
          document.body.insertAdjacentHTML('beforeend', html);
        });
      });
    }}

  hideSuggestions() {
    this.suggestionsTarget.classList.add('hidden');
  }

  showSuggestions() {
    this.suggestionsTarget.classList.remove('hidden');
  }
}
