express = require('express')
http = require('http')
request = require('request')
JSONStream = require('JSONStream')
{tickerResolver} = require('./helpers')
{getCloudantUrl} = require('./helpers')
{ObjectStringTransformStream} = require('../streams/ObjectStringTransformStream')
{CsvHeaderStream} = require('../streams/CsvHeaderStream')
{CsvRowStream} = require('../streams/CsvRowStream')

sendResponse = (identifier, res) ->

  request({url: "#{getCloudantUrl()}/facts2/_design/factsMainViews/_view/EntityPrefix?keys=[[\"http://www.sec.gov/CIK/#{identifier}\",\"us-gaap\"], [\"http://www.sec.gov/CIK/#{identifier}\",\"dei\"], [\"http://www.sec.gov/CIK/#{identifier}\",\"ext\"]]&include_docs=true&stale=update_after"})
  .pipe(JSONStream.parse('rows.*.doc'))
  .pipe(new CsvHeaderStream()).on('data', (data) ->

    res.write("http://www.xbrl.org/2003/instance/Entity,")
    res.write("http://www.xbrl.org/2003/instance/Concept,")
    res.write("http://www.xbrl.org/2003/instance/Period,")
    res.write("http://www.xbrl.org/2003/instance/Unit,")
    res.write("http://www.w3.org/2001/XMLSchema-instance/nil,")
    res.write("http://www.xbrl.org/2003/instance/Value,")
    res.write("http://www.xbrl.org/2003/instance/Decimals,")
    res.write("http://www.xbrl.org/2003/instance/Precision,")
    res.write("http://www.sec.gov/Archives/edgar/companyName,")
    res.write("http://www.sec.gov/Archives/edgar/filingDate,")
    res.write("http://www.sec.gov/Archives/edgar/accessionNumber,")
    res.write("http://www.sec.gov/Archives/edgar/fileNumber,")
    res.write("http://www.sec.gov/Archives/edgar/url,")
    res.write("http://xbrl.sec.gov/Amendment,")
    res.write("http://xbrl.sec.gov/FiscalYear,")

    if data.length > 0
      res.write("http://xbrl.sec.gov/FiscalPeriod,")
    else
      res.end("http://xbrl.sec.gov/FiscalPeriod\n")

    if data.length > 0

      if data.length > 1
        for i in [0..data.length-2]
          res.write("#{data[i]},")

      res.write("#{data[data.length-1]}\n")

      request({url: "#{getCloudantUrl()}/facts2/_design/factsMainViews/_view/EntityPrefix?keys=[[\"http://www.sec.gov/CIK/#{identifier}\",\"us-gaap\"], [\"http://www.sec.gov/CIK/#{identifier}\",\"dei\"], [\"http://www.sec.gov/CIK/#{identifier}\",\"ext\"]]&include_docs=true&stale=update_after"})
      .pipe(JSONStream.parse('rows.*.doc'))
      .pipe(new CsvRowStream(data))
      .pipe(res)
  )

router = express.Router()

router.get(/\/csv\/([a-zA-Z0-9]+)/, (req, res) ->
  cikOrTicker = req.params[0]
  #elementName = req.params[1]
  cik = null

  if cikOrTicker.match(/[0-9]{10}/)
    sendResponse(cikOrTicker, elementName, res)
  else
    tickerResolver(cikOrTicker, (identifier) ->
      if not identifier?
        res.end('[]')
      else
        sendResponse(identifier.cik, res)))

module.exports = router