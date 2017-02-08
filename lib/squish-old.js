(function() {
  var isSquishable, pageForUrl, showPage, supportsSquish, triggerEvent;

  triggerEvent = function(name, element) {
    var event;
    if (document.createEvent) {
      event = document.createEvent("HTMLEvents");
      event.initEvent(name, true, true);
    } else {
      event = document.createEventObject();
      event.eventType = name;
    }
    if (document.createEvent) {
      return element.dispatchEvent(event);
    } else {
      return element.fireEvent("on" + event.eventType, event);
    }
  };

  showPage = function(page) {
    var doc, _ref;
    doc = document.implementation.createHTMLDocument("");
    doc.open('replace');
    doc.write(page.body);
    doc.close();
    document.documentElement.replaceChild(doc.body, document.body);
    window.scrollTo(0, 0);
    if ((_ref = window._gaq) != null) _ref.push(['_trackPageView']);
    triggerEvent('squish:load', window);
    window.currentSquishPage = page;
    return false;
  };

  window.currentSquishPage = document.location.pathname;

  window.onpopstate = function(event) {
    return window.onpopstate = function(event) {
      var page, url;
      if (document.location.pathname === window.currentSquishPage) return;
      if (!event.state && document.readyState === "complete") {
        url = document.location.pathname;
        if (url[0] === "/") url = url.substring(1);
        page = pageForUrl(url);
        if (page && page !== window.currentSquishPage) {
          window.currentSquishPage = page;
          return showPage(page);
        }
      }
    };
  };

  supportsSquish = function() {
    var _ref;
    return window.history && window.history.pushState && window.history.replaceState && window.history.state !== void 0 && (((_ref = document.implementation) != null ? _ref.createHTMLDocument : void 0) != null);
  };

  pageForUrl = function(url) {
    var hash, page;
    url = url.replace(document.location.origin + '/', '');
    hash = url.split("#")[1];
    url = url.split("#")[0];
    url = url + ".html";
    page = window.pages[url];
    page || (page = window.pages[url.replace(".html", "")]);
    return page;
  };

  isSquishable = function(el) {
    var parent, thisElementIsSquishable;
    if (!el) return false;
    thisElementIsSquishable = el.nodeName === 'A' && el.href && /\.html/.test(el.href) && !el.hasAttribute('data-no-squish') && el.href.split("#")[1] !== "none";
    if (thisElementIsSquishable) return el;
    parent = isSquishable(el.parentNode);
    if (parent) return parent;
    return false;
  };

  if (supportsSquish) {
    document.addEventListener('click', function(e) {
      var el, hash, page, squishableElement, url;
      var _this = this;
      el = e.target;
      squishableElement = isSquishable(el);
      if (!squishableElement) return;
      if (squishableElement) {
        url = squishableElement.href;
        url = url.replace(document.location.origin + '/', '');
        hash = url.split("#")[1];
        url = url.split("#")[0];
        page = pageForUrl(url);
        if (page) {
          e.preventDefault();
          url = url.replace(".html", "");
          window.history.pushState('', page.title, document.location.origin + "/" + url);
          document.getElementsByTagName('title')[0].innerHTML = page.title;
          showPage(page);
          setTimeout(function() {
            if (hash) return location.hash = hash;
          }, 100);
          return false;
        }
      }
    });
    window.pages = "{{SQUISH}}";
  }

}).call(this);
