stream = require('stream')
{Fact} = require('../model/Fact')

class exports.CsvRowStream extends stream.Transform

  constructor: (@dimensions) ->
    super
      objectMode: true

  _transform: (chunk, enc, next) ->

    rowString = chunk["http://www.xbrl.org/2003/instance/Entity"] + ',' + \
      chunk["http://www.xbrl.org/2003/instance/Concept"] + ',' + \
      chunk["http://www.xbrl.org/2003/instance/Period"] + ',' + \
      chunk["http://www.xbrl.org/2003/instance/Unit"] + ',' + \
      chunk["http://www.w3.org/2001/XMLSchema-instance/nil"] + ',' + \
      chunk["http://www.xbrl.org/2003/instance/Value"] + ','
    if chunk["http://www.xbrl.org/2003/instance/Decimals"]? then rowString += chunk["http://www.xbrl.org/2003/instance/Decimals"] + ','
    if chunk["http://www.xbrl.org/2003/instance/Precision"]? then rowString += chunk["http://www.xbrl.org/2003/instance/Precision"] + ','
    rowString += chunk["http://www.sec.gov/Archives/edgar/companyName"] + ',' + \
      chunk["http://www.sec.gov/Archives/edgar/filingDate"] + ',' + \
      chunk["http://www.sec.gov/Archives/edgar/accessionNumber"] + ',' + \
      chunk["http://www.sec.gov/Archives/edgar/fileNumber"] + ',' + \
      chunk["http://www.sec.gov/Archives/edgar/url"] + ',' + \
      chunk["http://xbrl.sec.gov/Amendment"] + ',' + \
      chunk["http://xbrl.sec.gov/FiscalYear"] + ',' + \
      chunk["http://xbrl.sec.gov/FiscalPeriod"]

    if (@dimensions.length > 0)
      rowString += ','

      if (@dimensions.length > 1)
        for i in [0..@dimensions.length-2]
          member = chunk[@dimensions[i]]
          rowString += if member? then "#{member}," else ","

      rowString += if chunk[@dimensions.length-1]? then "#{chunk[@dimensions.length-1]}\n" else "\n"
    else
      rowString += "\n"

    @push(rowString)
    next()
