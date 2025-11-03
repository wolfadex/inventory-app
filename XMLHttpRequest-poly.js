class XMLHttpRequest {
  _headers = [];
  _eventLoad = () => {};
  _eventError = () => {};
  _eventTimeout = () => {};
  _responseHeaders = "";
  _aborted = false;
  _method = "GET";
  _url = "";

  withCredentials = false;
  timeout = 0;
  status = 200;
  statusText = "OK";
  responseUrl = "";
  responseType = "";
  response = null;

  async _respond(response) {
    if (this._aborted) {
      return;
    }

    const respHeaders = [];

    for (const [name, value] of response.headers.entries()) {
      respHeaders.push(`${name}: ${value}`);
    }

    this._responseHeaders = respHeaders.join("\r\n");
    this.status = response.status;
    this.statusText = response.statusText;
    this.responseUrl = response.url;
    this.responseType = response.type;

    const contentType = response.headers.get("content-type");

    switch (contentType) {
      case "application/json":
        this.response = await response.text();
        break;
      default:
        this.response = await response.arrayBuffer();
    }

    this._eventLoad(this.response);
  }

  // XMLHttpRequest supported API
  getAllResponseHeaders() {
    return this._responseHeaders;
  }

  setRequestHeader(name, value) {
    this._headers.push({ name, value });
  }

  open(method, url, performAsync) {
    this._method = method;
    this._url = url;
    return;
  }

  addEventListener(name, callback) {
    switch (name) {
      case "load":
        this._eventLoad = callback;
        break;
      case "error":
        this._eventError = callback;
        break;
      case "timeout":
        this._eventTimeout = callback;
        break;
    }
  }

  abort() {
    this._aborted = true;
  }

  async send(body) {
    try {
      const headers = new Headers();

      this._headers.forEach(({ name, value }) => {
        headers.set(name, value);
      });

      const request = new Request(this._url, {
        method: this._method,
        body,
        headers,
        // credentials: this.withCredentials ? "same-origin" : "omit",
      });
      if (this.timeout <= 0) {
        const response = await fetch(request);

        this._respond(response);
      } else {
        const timeoutPromise = new Promise((resolve) => {
          setTimeout(resolve, this.timeout, "timeout");
        });
        const requestPromise = fetch(request);
        const response = await Promise.race([timeoutPromise, requestPromise]);

        if (response === "timeout") {
          this._eventTimeout();
        } else {
          this._respond(response);
        }
      }
    } catch (error) {
      console.error("REQ error", error);
      this._eventError(error);
    }
  }
}

globalThis.XMLHttpRequest = XMLHttpRequest;
