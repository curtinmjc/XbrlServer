express = require('express')
JSONStream = require('JSONStream')
request = require('request')
{getCloudantUrl} = require('./helpers')
router = express.Router()

router.get('/size', (req, res) ->

  cloudantUri = "#{getCloudantUrl()}/facts2/_design/factsMainViews/_view/EntityConceptName?stale=update_after"

  request({url: cloudantUri})
  .pipe(JSONStream.parse('rows.*.value')).on('data', (data) ->
    res.end(JSON.stringify(data))
  )
)

module.exports = router