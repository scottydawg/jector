'use strict'

contexts = {}

exports.context = (namespace) ->
  unless contexts[namespace]?
    contexts[namespace] = new Context(namespace)

  return contexts[namespace]

exports.release = (namespace) ->
  context = contexts[namespace]
  delete contexts[namespace]
  return context


