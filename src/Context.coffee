class Context

  constructor: (@namespace) ->
    @pending = {}
    @singletons = {}
    @factories = {}
    @dependees = {}

  factory: (name, fn) ->
    @_assertNameAvailability(name)
    return @factories[name] = @_createFactory(name, fn)

  _assertNameAvailability: (name) ->
    if @singletons[name]? or @pending[name]? or @factories[name]?
      throw redundantDependencyNameError(name)

  _createFactory: (name, fn) ->
    return (depChain=[]) =>
      if depChain.indexOf(name) > -1
        throw circularDependencyError(name, depChain)
      return @_dynamicInstance(name, fn, pushToCopy(depChain, name))

  _dynamicInstance: (name, fn, depChain) ->
    constructorArgs = @_argsForFn(name, fn, depChain)
    fnInstance = Object.create(fn.prototype)
    return fn.apply(fnInstance, constructorArgs) ? fnInstance

  _argsForFn: (name, fn, depChain) ->
    argNames = fn._needs ? getArgNames(fn)
    return argNames.map (argName) =>
      @_dependsOn(argName, name)
      if (instance = @_get(argName, depChain))?
        return instance
      else throw unfulfilledDependencyError(argName)

  _dependsOn: (dependee, dependant) ->
    unless @dependees[dependee]?
      @dependees[dependee] = {}
    @dependees[dependee][dependant] = true

  singleton: (name, type) ->
    @_assertNameAvailability(name)
    @pending[name] = @_createSingleton(name, type)

    return () =>
      return @_processPending().singletons[name]

  _createSingleton: (name, type) ->
    return (depChain=[]) =>
      if (instance = @singletons[name])?
        return instance
      return @singletons[name] = @_createFactory(name, type)(depChain)

  _processPending: ->
    for name, processor of @pending
      processor()
      delete @pending[name]
    return @

  value: (name, instance) ->
    @_assertNameAvailability(name)
    return @singletons[name] = instance

  get: (name) ->
    return @_get(name)

  _get: (name, depChain=[]) ->
    if (fn = @factories[name])?
      return fn(depChain)

    if (processor = @pending[name])?
      return processor(depChain)

    return @singletons[name]

  dependants: (name) ->
    if (processor = @pending[name])?
      processor()
    return (key for key, value of @dependees[name])

