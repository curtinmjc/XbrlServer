stream = require('stream')

class exports.UniqueArrayWriteStream extends stream.Writable

  constructor: (@myArray, @keySelector, @valueSelector, @limit) ->
    super
      objectMode: true

  _write: (chunk, enc, next) ->

    if (Object.keys(@myArray).length < @limit)
      @myArray[chunk[@keySelector]] = chunk[@valueSelector]

    next()