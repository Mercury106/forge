(function() {
  $(function() {
    var retinafy;
    $(window).scroll(function() {
      if ($(window).scrollTop() >= 210) {
        return $('body').addClass('minimize');
      } else {
        return $('body').removeClass('minimize');
      }
    });
    $(window).scroll(function() {
      if ($(window).scrollTop() >= 20) {
        return $('body').addClass('scrolled');
      } else {
        return $('body').removeClass('scrolled');
      }
    });
    $('span.burger').on('click', function() {
      return $('#main nav').toggleClass('expand');
    });
    retinafy = function() {
      if (window.previousDevicePixelRatio !== window.devicePixelRatio) {
        window.previousDevicePixelRatio = window.devicePixelRatio;
        $('*[data-src][data-retina-src]').each(function() {
          return $(this).attr('src', $(this).data(window.devicePixelRatio > 1 ? 'retina-src' : 'src'));
        });
        return $('*[data-style][data-retina-style]').each(function() {
          return $(this).attr('style', $(this).data(window.devicePixelRatio > 1 ? 'retina-style' : 'style'));
        });
      }
    };
    setInterval(retinafy, 1000);
    return retinafy();
  });

}).call(this);
