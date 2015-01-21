describe 'Context', ->

  jector = require(process.cwd() + '/dist/jector')
  ns = 'ContextTest'
  context = {}

  beforeEach ->
    jector.release(ns)
    context = jector.context(ns)

  describe 'singleton', ->

    it 'enables retrieval of a single instance of the type provided', ->
      fn = context.singleton('slab', Slab)
      expect(fn instanceof Function).toBe(true)
      expect(fn() instanceof Slab).toBe(true)

    it 'injects registered singleton when constructor argument name matches named singleton', ->
      slabFn = context.singleton('slab', Slab)
      frameFn = context.singleton('frame', Frame)
      expect(frameFn().slab).toBe(slabFn())

    it 'processes pending singleton when when requested object depends on it', ->
      frameFn = context.singleton('frame', Frame)
      slabFn = context.singleton('slab', Slab)
      expect(frameFn().slab).toBe(slabFn())

    it 'returns existing singleton if one is registered', ->
      slabFn1 = context.singleton('slab', Slab)
      expect(slabFn1()).toBe(context.get('slab'))

    it 'fulfills nested dependencies', ->
      roofFn = context.singleton('roof', Roof)
      trussFn = context.singleton('truss', Truss)
      frameFn = context.singleton('frame', Frame)
      slabFn = context.singleton('slab', Slab)

      roof = roofFn()
      truss = trussFn()
      frame = frameFn()
      slab = slabFn()

      expect(roof.truss).toBe(truss)
      expect(roof.frame).toBe(frame)
      expect(roof.slab).toBe(slab)
      expect(truss.frame).toBe(frame)
      expect(truss.slab).toBe(slab)
      expect(frame.slab).toBe(slab)

    it 'throws when a self dependency is encountered', ->
      frameFn = context.singleton('slab', Frame)
      expect(-> frameFn())
        .toThrow('Circular dependency detected: slab > slab')

    it 'throws when a circular dependency is encountered', ->
      context.singleton('rock', Rock)
      context.singleton('scissors', Scissors)
      paperFn = context.singleton('paper', Paper)
      expect(-> paperFn())
        .toThrow('Circular dependency detected: rock > scissors > paper > rock')

    it 'throws when the same name is used twice (and instantiation is pending)', ->
      context.singleton('slab', Slab)
      expect(-> context.singleton('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when the same name is used twice (and instantiation has occurred)', ->
      context.singleton('slab', Slab)()
      expect(-> context.singleton('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a singleton name is already a factory name', ->
      context.factory('slab', Slab)
      expect(-> context.singleton('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a dependency cannot be fulfilled', ->
      frameFn = context.singleton('frame', Frame)
      expect(-> frameFn())
        .toThrow("Could not fulfill dependency named 'slab'")

    it 'uses min-safe injection when provided', ->
      slabFn = context.singleton('slab', Slab)
      frameFn = context.singleton('frame', Frame)
      minSafe = context.singleton('minSafe', MinSafe)()
      expect(minSafe.truss).toBe(slabFn())
      expect(minSafe.roof).toBe(frameFn())

  describe 'factory', ->

    it 'returns a factory for invoking the function provided', ->
      invocationCount = 0
      thingFn = jasmine.createSpy('factoryFn').andCallFake ->
        return "thing#{++invocationCount}"

      thingFactory = context.factory('thing', thingFn)
      expect(thingFactory()).toEqual('thing1')
      expect(thingFactory()).toEqual('thing2')
      expect(thingFn.calls.length).toEqual(2)

    it 'provides dependencies to the factory function', ->
      thingFn = (slab, frame) ->
        return [slab, frame]

      thingFactory = context.factory('thing', thingFn)
      slabFn = context.singleton('slab', Slab)
      frameFn = context.singleton('frame', Frame)

      expect(thingFactory()).toEqual([slabFn(), frameFn()])

    it 'allows factory instantiation of a type and provides dependencies', ->
      slab = context.singleton('slab', Slab)()
      frameFactory = context.factory('frameFactory', Frame)
      frame1 = frameFactory()
      frame2 = frameFactory()
      expect(frame1.slab).toBe(slab)
      expect(frame2.slab).toBe(slab)

    it 'injects a generated instance for named dependencies', ->
      context.factory('slab', Slab)
      frameFactory = context.factory('frameFactory', Frame)
      frame1 = frameFactory()
      frame2 = frameFactory()
      expect(frame1.slab).not.toBe(frame2.slab)

    it 'throws when a self dependency is encountered', ->
      fn = (thing) -> return
      factory = context.factory('thing', fn)
      expect(-> factory())
        .toThrow('Circular dependency detected: thing > thing')

    it 'throws when a circular dependency is encountered', ->
      context.factory('rock', Rock)
      context.factory('scissors', Scissors)
      paperFn = context.factory('paper', Paper)
      expect(-> paperFn())
        .toThrow('Circular dependency detected: paper > rock > scissors > paper')

    it 'throws when the same factory name is used twice', ->
      context.factory('slab', Slab)
      expect(-> context.factory('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a factory name is already a singleton name (and instantiation is pending)', ->
      context.singleton('slab', Slab)
      expect(-> context.factory('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a factory name is already a singleton name (and instantiation has occurred)', ->
      context.singleton('slab', Slab)()
      expect(-> context.factory('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a dependency cannot be fulfilled', ->
      frameFn = context.factory('frame', Frame)
      expect(-> frameFn())
        .toThrow("Could not fulfill dependency named 'slab'")

    it 'uses min-safe injection when provided', ->
      context.factory('slab', Slab)
      context.factory('frame', Frame)
      minSafe = context.factory('minSafe', MinSafe)()
      expect(minSafe.truss instanceof Slab).toBe(true)
      expect(minSafe.roof instanceof Frame).toBe(true)

  describe 'value', ->

    instance = {}

    beforeEach ->
      instance = new Frame({id: 'mockSlab'})

    it 'returns the value provided', ->
      value = context.value('frame', instance)
      expect(value).toBe(instance)

    it 'performs no injection', ->
      context.singleton('slab', Slab)
      value = context.value('frame', instance)
      expect(value.slab.id).toBe('mockSlab')

    it 'provides declared value as a dependency', ->
      slab = new Slab()
      context.value('slab', slab)
      frameFn = context.factory('frame', Frame)
      frame1 = frameFn()
      frame2 = frameFn()
      expect(frame1.slab).toBe(slab)
      expect(frame2.slab).toBe(slab)
      expect(frame2).not.toBe(frame1)

    it 'throws when a value name is already in use', ->
      context.value('slab', Slab)
      expect(-> context.value('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a value name is already a singleton name (and instantiation is pending)', ->
      context.singleton('slab', Slab)
      expect(-> context.value('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a value name is already a singleton name (and instantiation has occurred)', ->
      context.singleton('slab', Slab)()
      expect(-> context.value('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

    it 'throws when a value name is already a factory name', ->
      context.factory('slab', Slab)
      expect(-> context.value('slab', Slab))
        .toThrow("Dependency name 'slab' was already used")

  describe 'get', ->

    it 'returns nothing if named instance does not exist', ->
      expect(context.get('slab')).not.toBeDefined()

    it 'returns a named instance, if one has been created', ->
      slab = context.singleton('slab', Slab)()
      expect(context.get('slab')).toBe(slab)

    it 'processes pending instance if named instance is requested', ->
      slabFn = context.singleton('slab', Slab)
      expect(context.get('slab')).toBe(slabFn())

    it 'returns a generated instance if a factory object is requested', ->
      context.factory('slab', Slab)
      slab1 = context.get('slab')
      slab2 = context.get('slab')
      expect(slab2).not.toBe(slab1)

    it 'returns a value when requested', ->
      rock = new Rock({})
      context.value('rock', rock)
      expect(context.get('rock')).toBe(rock)


class Slab
  constructor: () ->
    @id = Math.random()

class Frame
  constructor: (@slab) ->

class Truss
  constructor: (@slab, @frame) ->

class Roof
  constructor: (@slab, @frame, @truss) ->


class Rock
  constructor: (@scissors) ->

class Scissors
  constructor: (@paper) ->

class Paper
  constructor: (@rock) ->


class MinSafe
  constructor: (@truss, @roof) ->

MinSafe._needs = ['slab', 'frame']