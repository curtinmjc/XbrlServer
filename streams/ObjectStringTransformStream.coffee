stream = require('stream')

class exports.ObjectStringTransformStream extends stream.Transform

  constructor: () ->
    @first = true
    super
      objectMode: true

  _transform: (chunk, enc, next) ->

    if (@first)
      @push('[')
      @first  = false
    else
      @push(',\n')

    @push(JSON.stringify(chunk))

    next()

  _flush: (next) ->
    if (@first)
      @push('[]')
    else
      @push(']')
    next()