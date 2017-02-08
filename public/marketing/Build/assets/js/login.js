(function() {
  var loginOverlay;

  loginOverlay = {
    setup: function() {
      var _this = this;
      $('#overlay').on('click', function(e) {
        return _this.hide();
      });
      $('.register.button').on('click', function(e) {
        return _this.register();
      });
      $('.login a, .login-tab a, a.login').on('click', function(e) {
        e.preventDefault();
        return _this.login();
      });
      return $('.register.button, .login a, .login-tab a').click(function(e) {
        e.stopPropagation();
        return e.preventDefault();
      });
    },
    show: function() {
      this.spinner.hide();
      $('#overlay').fadeIn();
      return $('#modal').addClass('animate show');
    },
    hide: function() {
      $('#modal').removeClass('animate');
      setTimeout(function() {
        return $('#modal').removeClass('show');
      }, 100);
      return setTimeout(function() {
        return $('#overlay').fadeOut();
      }, 150);
    },
    success: function() {
      var _this = this;
      $('body').css('background', '#fff').addClass('hidden');
      $('#type').addClass('hide');
      return setTimeout((function() {
        return document.location = "/";
      }), 500);
    },
    login: function() {
      event.preventDefault();
      this.show();
      $('#modal #login').show();
      $('#modal #register').hide();
      return $('#login form input[type=email]').eq(0).focus();
    },
    register: function() {
      this.show();
      $('#modal #login').hide();
      $('#modal #register').show();
      return $('#modal #register input[type=text]').eq(0).focus();
    },
    shake: function() {
      var frame, modal, shakewidth, _i, _results;
      modal = $('#modal');
      shakewidth = 20;
      _results = [];
      for (frame = _i = 0; _i <= 5; frame = ++_i) {
        shakewidth = -shakewidth;
        _results.push(modal.animate({
          'margin-left': "" + (shakewidth - 200) + "px"
        }, 50));
      }
      return _results;
    },
    error: function() {
      this.spinner.hide();
      this.shake();
      $('#modal input[type="password"]').select();
      $('#login form input').addClass('error');
      return setTimeout((function() {
        return $('#login form input').removeClass('error');
      }), 1000);
    },
    spinner: {
      options: {
        lines: 13,
        length: 4,
        width: 2,
        radius: 4,
        corners: 1,
        rotate: 0,
        direction: 1,
        color: '#000',
        speed: 1,
        trail: 30,
        shadow: false,
        hwaccel: true,
        className: 'spinner',
        zIndex: 2e9,
        top: 'auto',
        left: 'auto'
      },
      hide: function() {
        $('#login').fadeTo(50, 1.0);
        return $('#modal .spinner').remove();
      },
      show: function() {
        var loadingSpinner;
        $('#login').fadeTo(50, 0.3);
        loadingSpinner = new Spinner(this.options).spin();
        return $(loadingSpinner.el).appendTo($('.viewport'));
      }
    }
  };

  $(function() {
    return loginOverlay.setup();
  });

}).call(this);
