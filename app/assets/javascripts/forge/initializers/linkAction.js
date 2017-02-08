Ember.Handlebars.registerHelper('linkAction', function (name) {
    var options = [].slice.call(arguments, -1)[0];
    var params = [].slice.call(arguments, 1, -1);

    var hash = options.hash;

    hash.namedRoute = name;
    hash.currentWhen = hash.currentWhen || name;

    hash.parameters = {
        context: this,
        options: options,
        params: params
    };

    var LinkView = Ember.LinkView.extend({
        didInsertElement: function () {
            this.eventManager = Ember.Object.create({});
            this.eventManager.click = function () {
                return false;
            };
            this.eventManager[hash.on] = function (e, v) {
                Ember.LinkView.prototype.click.call(v, e);
            }
        }
    })

    return Ember.Handlebars.helpers.view.call(this, LinkView, options);
});
