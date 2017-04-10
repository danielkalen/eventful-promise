var EventfulPromise,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

EventfulPromise = (function(superClass) {
  extend(EventfulPromise, superClass);

  function EventfulPromise(task) {
    EventfulPromise.__super__.constructor.apply(this, arguments);
    this.init(task);
  }

  EventfulPromise.prototype.init = function(task1) {
    this.task = task1;
    this.taskPromise = Promise.resolve(typeof this.task === 'function' ? this.task.call(this) : this.task);
    return this;
  };

  EventfulPromise.prototype.then = function() {
    var ref;
    return (ref = this.taskPromise).then.apply(ref, arguments);
  };

  EventfulPromise.prototype["catch"] = function() {
    var ref;
    return (ref = this.taskPromise)["catch"].apply(ref, arguments);
  };

  return EventfulPromise;

})(require('events'));

module.exports = EventfulPromise;
