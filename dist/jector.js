(function() {
  var ARGUMENT_NAMES, Context, STRIP_COMMENTS, circularDependencyError, contexts, getArgNames, pushToCopy, redundantDependencyNameError, unfulfilledDependencyError;

  Context = (function() {
    function Context(namespace) {
      this.namespace = namespace;
      this.pending = {};
      this.singletons = {};
      this.factories = {};
    }

    Context.prototype.factory = function(name, fn) {
      this._assertNameAvailability(name);
      return this.factories[name] = this._createFactory(name, fn);
    };

    Context.prototype._assertNameAvailability = function(name) {
      if ((this.singletons[name] != null) || (this.pending[name] != null) || (this.factories[name] != null)) {
        throw redundantDependencyNameError(name);
      }
    };

    Context.prototype._createFactory = function(name, fn) {
      return (function(_this) {
        return function(depChain) {
          if (depChain == null) {
            depChain = [];
          }
          if (depChain.indexOf(name) > -1) {
            throw circularDependencyError(name, depChain);
          }
          return _this._dynamicInstance(name, fn, pushToCopy(depChain, name));
        };
      })(this);
    };

    Context.prototype._dynamicInstance = function(name, fn, depChain) {
      var constructorArgs, fnInstance, _ref;
      constructorArgs = this._argsForFn(name, fn, depChain);
      fnInstance = Object.create(fn.prototype);
      return (_ref = fn.apply(fnInstance, constructorArgs)) != null ? _ref : fnInstance;
    };

    Context.prototype._argsForFn = function(name, fn, depChain) {
      var argNames, _ref;
      argNames = (_ref = fn._needs) != null ? _ref : getArgNames(fn);
      return argNames.map((function(_this) {
        return function(argName) {
          var instance;
          if ((instance = _this._get(argName, depChain)) != null) {
            return instance;
          } else {
            throw unfulfilledDependencyError(argName);
          }
        };
      })(this));
    };

    Context.prototype.singleton = function(name, type) {
      this._assertNameAvailability(name);
      this.pending[name] = this._createSingleton(name, type);
      return (function(_this) {
        return function() {
          return _this._processPending().singletons[name];
        };
      })(this);
    };

    Context.prototype._createSingleton = function(name, type) {
      return (function(_this) {
        return function(depChain) {
          var instance;
          if (depChain == null) {
            depChain = [];
          }
          if ((instance = _this.singletons[name]) != null) {
            return instance;
          }
          return _this.singletons[name] = _this._createFactory(name, type)(depChain);
        };
      })(this);
    };

    Context.prototype._processPending = function() {
      var name, processor, _ref;
      _ref = this.pending;
      for (name in _ref) {
        processor = _ref[name];
        processor();
        delete this.pending[name];
      }
      return this;
    };

    Context.prototype.value = function(name, instance) {
      this._assertNameAvailability(name);
      return this.singletons[name] = instance;
    };

    Context.prototype.get = function(name) {
      return this._get(name);
    };

    Context.prototype._get = function(name, depChain) {
      var fn, processor;
      if (depChain == null) {
        depChain = [];
      }
      if ((fn = this.factories[name]) != null) {
        return fn(depChain);
      }
      if ((processor = this.pending[name]) != null) {
        return processor(depChain);
      }
      return this.singletons[name];
    };

    return Context;

  })();

  STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg;

  ARGUMENT_NAMES = /([^\s,]+)/g;

  pushToCopy = function(array, item) {
    var arr;
    arr = array.concat();
    arr.push(item);
    return arr;
  };

  getArgNames = function(func) {
    var fnStr, result;
    fnStr = func.toString().replace(STRIP_COMMENTS, '');
    result = fnStr.slice(fnStr.indexOf('(') + 1, fnStr.indexOf(')')).match(ARGUMENT_NAMES);
    return result != null ? result : [];
  };

  circularDependencyError = function(name, depChain) {
    return new Error("Circular dependency detected: " + (pushToCopy(depChain, name).join(' > ')));
  };

  redundantDependencyNameError = function(name) {
    return new Error("Dependency name '" + name + "' was already used");
  };

  unfulfilledDependencyError = function(name) {
    return new Error("Could not fulfill dependency named '" + name + "'");
  };

  'use strict';

  contexts = {};

  exports.context = function(namespace) {
    if (contexts[namespace] == null) {
      contexts[namespace] = new Context(namespace);
    }
    return contexts[namespace];
  };

  exports.release = function(namespace) {
    var context;
    context = contexts[namespace];
    delete contexts[namespace];
    return context;
  };

}).call(this);
