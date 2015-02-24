express = require('express')
JSONStream = require('JSONStream')
request = require('request')
router = express.Router()

#router.get(/\/elements\/([a-zA-Z0-9]+)/, (req, res) ->
#
#  identifier = req.params[0]
#  term = req.query.term
#  cloudantUri = "https://f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix:f36e6b9ea5c38e9e4347fec14c7847745e31b655f597346eb36d0bb5a8d7ed13@f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix.cloudant.com/facts/_design/factsSearchIndexes/_search/conceptsByEntity?q=\"#{identifier}\"%20AND%20conceptNameSplit:#{term}&counts=[\"conceptNameSplit\"]&limit=0"
#  request({url: cloudantUri})
#  .pipe(JSONStream.parse('counts.conceptNameSplit')).on('data', (data) ->
#
#    keys = []
#    for k,v of data
#      keys.push(k)
#
#    keys.sort((a, b) -> data[b] - data[a])
#
#    if keys.length > 0
#      for i in [0..keys.length-1]
#        keys[i] = keys[i].replace(/\s/g, "")
#
#    res.end(JSON.stringify(keys))
#  )
#)

router.get(/\/elements/, (req, res) ->

  identifier = req.query.identifier
  term = req.query.term
  cloudantUri = "https://0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix.cloudant.com/facts/_design/factsMainSearchIndexes/_search/EntitySplitConcept?q=entity:\"#{identifier}\"%20AND%20conceptNameSplit:#{term}&counts=[\"conceptNameSplit\"]&limit=0"
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