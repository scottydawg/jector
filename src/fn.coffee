
STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg
ARGUMENT_NAMES = /([^\s,]+)/g

pushToCopy = (array, item) ->
  arr = array.concat()
  arr.push(item)
  return arr

getArgNames = (func) ->
  # Adapted from http://stackoverflow.com/questions/1007981/how-to-get-function-parameter-names-values-dynamically-from-javascript
  fnStr = func.toString().replace(STRIP_COMMENTS, '')
  result = fnStr.slice(fnStr.indexOf('(') + 1, fnStr.indexOf(')')).match(ARGUMENT_NAMES)
  return result ? []

circularDependencyError = (name, depChain) ->
  return new Error("Circular dependency detected: #{pushToCopy(depChain, name).join(' > ')}")

redundantDependencyNameError = (name) ->
  return new Error("Dependency name '#{name}' was already used")

unfulfilledDependencyError = (name) ->
  return new Error("Could not fulfill dependency named '#{name}'")

