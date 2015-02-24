express = require('express')
http = require('http')
async = require('async')
reduce = require("stream-reduce");
request = require('request')
router = express.Router()
{getParsedFactData} = require('./helpers')
{unEscape} = require('./helpers')

getParsedFactDataInternal = (set, callback) ->
  getParsedFactData(set.identifier, set.conceptName, (data) -> callback(null, data))

respondWithEmpty = (res) ->
  res.render('index', {pageData: {facts: null, sets: [], series: {}}})

#getFriendlyNamesInternal = (set, callback) ->
#  splitSet = set.split(':')
#  cloudantUri = "http://f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix:f36e6b9ea5c38e9e4347fec14c7847745e31b655f597346eb36d0bb5a8d7ed13@f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix.cloudant.com/entities/_design/entitiesViews/_view/entitiesBySchemaIdentifier?key=[\"http://www.sec.gov/CIK\", \"#{splitSet[0]}\"]&include_docs=true"
#
#  http.get(cloudantUri, (httpReadStream) ->
#    httpReadStream.pipe(reduce(((acc, data) ->
#      acc = acc + data
#      return acc), ''))
#    .on('data', (data) ->
#      jsonResults = JSON.parse(data)
#
#      if (not jsonResults.rows?)
#        callback(null, [])
#      else
#        callback(null, jsonResults.rows[0].doc)
#    )
#  )


router.get(/\/show\/([a-zA-Z0-9\-]+)/, (req, res) ->

  id = req.params[0]

  options = {
    uri: "https://0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix.cloudant.com/share/_design/shareMainViews/_view/UUID?key=\"#{id}\"&include_docs=true",
    method: 'GET',
  }

  request.get(options, (error, response, body) ->
    if (not error && response.statusCode is 200)

      responseBody = JSON.parse(body)

      if not responseBody.rows? or responseBody.rows.length is 0
        return respondWithEmpty(res)

      async.map(responseBody.rows[0].doc.sets, getParsedFactDataInternal, (err, results) ->
        concatResults = {}

        for item in results
          for k,v of item
            concatResults[k] = v

        res.render('index', {pageData: {facts: concatResults, sets: responseBody.rows[0].doc.sets, series: responseBody.rows[0].doc.series}})
      )
    else
      respondWithEmpty(res)
  )
)

#router.get(/\/show\/([a-zA-Z0-9]+)/, (req, res) ->
#
#  id = req.params[0]
#
#  options = {
#    uri: 'https://f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix:f36e6b9ea5c38e9e4347fec14c7847745e31b655f597346eb36d0bb5a8d7ed13@f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix.cloudant.com/share/' + id
#    method: 'GET',
#  }
#
#  request.get(options, (error, response, body) ->
#    if (not error && response.statusCode is 200)
#
#      responseBody = JSON.parse(body)
#
#      async.map(responseBody.sets, getFriendlyNamesInternal, (err, results) ->
#        friendlyNames = {}
#
#        for item in results
#          friendlyNames[item.identifier] = unEscape(item.name)
#
#        async.map(responseBody.sets, getParsedFactDataInternal, (err, results) ->
#          concatResults = {}
#
#          for item in results
#            for k,v of item
#              concatResults[k] = v
#
#          res.render('index', {pageData: {facts: concatResults, sets: responseBody.sets, series: responseBody.series, friendlyNames: friendlyNames}})
#        )
#      )
#    else
#      res.render('index', {pageData: {facts: null, sets: [], series: {}, friendlyNames: {}}})
#  )
#)

module.exports = router