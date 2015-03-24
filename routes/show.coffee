express = require('express')
http = require('http')
async = require('async')
reduce = require("stream-reduce");
request = require('request')
router = express.Router()
{getParsedFactData} = require('./helpers')
{unEscape} = require('./helpers')
{getCloudantUrl} = require('./helpers')

getParsedFactDataInternal = (set, callback) ->
  getParsedFactData(set.identifier, set.conceptName, (data) -> callback(null, data))

respondWithEmpty = (res) ->
  res.render('index', {pageData: {facts: null, sets: [], series: {}}})

router.get(/\/show\/([a-zA-Z0-9\-]+)/, (req, res) ->

  id = req.params[0]

  options = {
    uri: "#{getCloudantUrl()}/share/_design/shareMainViews/_view/UUID?key=\"#{id}\"&include_docs=true",
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

module.exports = router