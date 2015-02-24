express = require('express')
http = require('http')
request = require('request')
JSONStream = require('JSONStream')
{tickerResolver} = require('./helpers')
{ObjectStringTransformStream} = require('../streams/ObjectStringTransformStream')

sendResponse = (identifier, elementName, res) ->

  request({url: "https://0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix.cloudant.com/facts/_design/factsMainViews/_view/EntityConceptName?key=[\"http://www.sec.gov/CIK/#{identifier}\",\"#{elementName}\"]&include_docs=true&stale=update_after&reduce=false"})
  .pipe(JSONStream.parse('rows.*.doc'))
  .pipe(new ObjectStringTransformStream())
  .pipe(res)

router = express.Router()

router.get(/\/rawfacts\/([a-zA-Z0-9]+)\/(.+)/, (req, res) ->
  cikOrTicker = req.params[0]
  elementName = req.params[1]
  cik = null

  if cikOrTicker.match(/[0-9]{10}/)
    sendResponse(cikOrTicker, elementName, res)
  else
    tickerResolver(cikOrTicker, (identifier) ->
      if not identifier?
        res.end('[]')
      else
        sendResponse(identifier.cik, elementName, res)))

module.exports = router