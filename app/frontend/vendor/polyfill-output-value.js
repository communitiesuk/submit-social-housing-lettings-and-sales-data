if (window.HTMLOutputElement === undefined) {
    Object.defineProperty(HTMLUnknownElement.prototype, 'value', {
      get: function () {
        if (this.tagName === 'OUTPUT') {
          return this.textContent;
        }
      },
      set: function (newValue) {
        if (this.tagName === 'OUTPUT') {
          this.textContent = newValue;
        }
      }
    });
  }