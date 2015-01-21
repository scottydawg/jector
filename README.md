# jector
Simple, unobtrusive dependency injection.

### Simple
Jector uses constructor injection to provide dependencies by mapping a
    function's argument names to values in the injection context. It provides
    powerful IoC constructs with a minimalist API.

### Unobtrusive
Jector is designed to work along side your existing classes and module
    architecture. It doesn't require that you conform to a prescribed means of
    declaring modules or classes, relying instead on constructor argument names.
    (And even those can remain intact by using the [minsafe alternative to
    dependency declaration](#minsafe-dependency-declaration)).


## Usage

### Context Creation

`jector.context(namespace)`

Create a new injection context by providing a namespace. If the namespace has
    already been declared, the existing context is returned.

JavaScript:
```javascript
var jector = require('jector');
var context = jector.context('myNamespace');
console.log(context.namespace); // output 'myNamespace'
```

CoffeeScript:
```coffeescript
jector = require('jector')
context = jector.context('myNamespace')
console.log(context.namespace) # output 'myNamespace'
```


### Singletons

`context.singleton(dependencyName, constructorMethod)`

`singleton()` declares a named Singleton. The constructorMethod (which may be a
    class constructor or any other function) is invoked the first time the
    dependency is requested, and the instance is retained.

JavaScript:
```javascript
function Slab() {
  this.id = Math.random();
}

function Frame(slab) {
  this.slab = slab;
}

context.singleton('slab', Slab);
context.singleton('frame', Frame);

var frame = context.get('frame');
var slab = context.get('slab');

console.log(frame.slab === slab); // output 'true'
```

CoffeeScript:
```coffeescript
class Slab
  constructor: -> @id = Math.random()

class Frame
  constructor: (@slab) ->

context.singleton('slab', Slab)
context.singleton('frame', Frame)

frame = context.get('frame')
slab = context.get('slab')

console.log(frame.slab is slab); # output 'true'
```


### Factories

`context.factory(dependencyName, factoryMethod)`

`factory()` declares a factory method that will be invoked any time the named
    dependency is requested.

JavaScript:
```javascript
function Slab() {
  this.id = Math.random();
}

function Frame(slab) {
  this.slab = slab;
}

context.singleton('slab', Slab);
context.factory('frame', Frame);

var frame1 = context.get('frame');
var frame2 = context.get('frame');

console.log(frame1 === frame2); // output 'false'
console.log(frame1.slab === frame2.slab); // output 'true'
```

CoffeeScript:
```coffeescript
class Slab
  constructor: -> @id = Math.random()

class Frame
  constructor: (@slab) ->

context.singleton('slab', Slab)
context.factory('frame', Frame)

frame1 = context.get('frame')
frame2 = context.get('frame')

console.log(frame1 is frame2) # output 'false'
console.log(frame1.slab is frame2.slab) # output 'true'
```


### Values

`context.value(dependencyName, instance)`

`value()` registers an existing instance as a named dependency for injection.

JavaScript:
```javascript
function Slab() {
  this.id = Math.random();
}

function Frame(slab) {
  this.slab = slab;
}

var slab = new Slab()
context.value('slab', slab);
context.factory('frame', Frame);
var frame = context.get('frame');

console.log(frame.slab === slab); // output 'true'
```

CoffeeScript:
```coffeescript
class Slab
  constructor: -> @id = Math.random()

class Frame
  constructor: (@slab) ->

slab = new Slab()
context.value('slab', slab)
context.factory('frame', Frame)

frame = context.get('frame')

console.log(frame.slab is slab) # output 'true'
```


### Minsafe Dependency Declaration

Jector relies on constructor argument names to intuit an object's dependencies.
    Minification can obliterate those names. If you plan to minify your code,
    define a `_needs` Array on your constructor (or function), and this will be
    used instead of the function's argument names.

JavaScript:
```javascript
function Slab() {
  this.id = Math.random();
}

function Frame(s) {
  this.slab = s;
}
Frame._needs = ['slab'];

var slab = new Slab()
context.value('slab', slab);
context.factory('frame', Frame);
var frame = context.get('frame');

console.log(frame.slab === slab); // output 'true'
```

CoffeeScript:
```coffeescript
class Slab
  constructor: -> @id = Math.random()

class Frame
  constructor: (s) ->
    @slab = s
Frame._needs = ['slab']

slab = new Slab()
context.value('slab', slab)
context.factory('frame', Frame)
frame = context.get('frame')

console.log(frame.slab is slab) # output 'true'
```
