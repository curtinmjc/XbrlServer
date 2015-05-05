express = require('express')
JSONStream = require('JSONStream')
request = require('request')
{getCloudantUrl} = require('./helpers')
router = express.Router()

rotateText = (text, rotation) ->
# Surrogate pair limit
  bound = 0x10000;

  # Force the rotation an integer and within bounds, just to be safe
  rotation = parseInt(rotation) % bound;

  # Might as well return the text if there's no change
  if rotation is 0 then return text

  # Create string from character codes
  return String.fromCharCode.apply(null,
# Turn string to character codes
    text.split('').map((v) ->
# Return current character code + rotation
      return (v.charCodeAt() + rotation + bound) % bound)
  )

router.get(/\/elements/, (req, res) ->

  identifier = req.query.identifier
  term = req.query.term
  cloudantUri = "#{getCloudantUrl()}/factsdev/_design/factsMainSearchIndexes/_search/EntitySplitConcept?q=entity:\"#{identifier}\"%20AND%20conceptNameSplit:#{term}&counts=[\"conceptNameSplit\"]&limit=0"
  request({url: cloudantUri})
  .pipe(JSONStream.parse('counts.conceptNameSplit')).on('data', (data) ->

    keys = []
    for k,v of data
      keys.push(k)

    keys.sort((a, b) -> data[b] - data[a])

    results = []
    for key in keys
      prefix = rotateText(key.substring(0, key.indexOf(' ')), -325)
      name = key.substring(key.indexOf(' ') + 1, key.length).replace(/\s/g, "")
      results.push(prefix + ':' + name)

    res.end(JSON.stringify(results))
  )
)

module.exports = router