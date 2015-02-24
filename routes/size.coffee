express = require('express')
JSONStream = require('JSONStream')
request = require('request')
router = express.Router()

router.get('/size', (req, res) ->

  cloudantUri = "https://0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix.cloudant.com/facts/_design/factsMainViews/_view/EntityConceptName?stale=update_after"

  request({url: cloudantUri})
  .pipe(JSONStream.parse('rows.*.value')).on('data', (data) ->
    res.end(JSON.stringify(data))
  )
)
#
#    cloudantUri = "https://0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix:***REMOVED***@0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix.cloudant.com/facts/_design/factsMainViews/_view/EntityConceptName?stale=update_after"
#
#  http.get(cloudantUri, (httpReadStream) ->
#    httpReadStream.pipe(reduce(((acc, data) ->
#      acc = acc + data
#      return acc), ''))
#    .on('data', (data) ->
#      jsonResults = JSON.parse(data)
#
#      if (not jsonResults.rows?)
#        res.end('[]')
#        return
#
#      res.end(JSON.stringify(jsonResults.rows[0].value))
#    )
#  )
#
#)

module.exports = router