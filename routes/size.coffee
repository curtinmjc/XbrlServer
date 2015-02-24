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

module.exports = router