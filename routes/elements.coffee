express = require('express')
JSONStream = require('JSONStream')
request = require('request')
{getCloudantUrl} = require('./helpers')
router = express.Router()

router.get(/\/elements/, (req, res) ->

  identifier = req.query.identifier
  term = req.query.term
  cloudantUri = "#{getCloudantUrl()}/facts/_design/factsMainSearchIndexes/_search/EntitySplitConcept?q=entity:\"#{identifier}\"%20AND%20conceptNameSplit:#{term}&counts=[\"conceptNameSplit\"]&limit=0"
  request({url: cloudantUri})
  .pipe(JSONStream.parse('counts.conceptNameSplit')).on('data', (data) ->

    keys = []
    for k,v of data
      keys.push(k)

    keys.sort((a, b) -> data[b] - data[a])

    if keys.length > 0
      for i in [0..keys.length-1]
        keys[i] = keys[i].replace(/\s/g, "")

    res.end(JSON.stringify(keys))
  )
)

module.exports = router