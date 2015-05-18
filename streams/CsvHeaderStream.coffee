stream = require('stream')
{Fact} = require('../model/Fact')

class exports.CsvHeaderStream extends stream.Transform

  constructor: () ->
    @dimensions = {}
    super
      objectMode: true

  _transform: (chunk, enc, next) ->

    for k,v of new Fact(chunk).GetDimensions()
      @dimensions[k] = true

    next()

  _flush: (next) ->

    @push((k for k,v of @dimensions))
    next()