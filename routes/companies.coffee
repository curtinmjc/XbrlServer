express = require('express')
{tickerResolver} = require('./helpers')
{recursiveCloudantSearch} = require('./helpers')
{unEscape} = require('./helpers')
JSONStream = require('JSONStream')
request = require('request')
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


#router.get(/\/companies/, (req, res) ->
#
#  term = req.query.term
#
#  tickerResolver(term, (tickerLookup) ->
#
#    designDocUri = "http://f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix:f36e6b9ea5c38e9e4347fec14c7847745e31b655f597346eb36d0bb5a8d7ed13@f0884b3f-8c7e-44fe-8132-da237a0197b0-bluemix.cloudant.com/entities/_design/entitiesSearches/_search/nameSearch"
#    query = "\"http://www.sec.gov/CIK\"%20AND%20name:#{term}*"
#
#    index = {}
#    recursiveCloudantSearch(designDocUri, query, 'identifier', 'name', {value: null}, index, 100,  ->
#
#      if tickerLookup?
#        index[tickerLookup.cik] = tickerLookup.name
#
#      results = []
#      for k,v of index
#        results.push({id: k, value: unEscape(v)})
#
#      res.end(JSON.stringify(results))
#    )
#  )
#)

router.get(/\/companies/, (req, res) ->

  term = req.query.term
  tickerResolver(term, (tickerLookup) ->

    cloudantUri = "https://0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix.cloudant.com/facts/_design/factsMainSearchIndexes/_search/EntityCipherCompanyName?q=companyName:#{term}&counts=[\"companyName\"]&limit=0"
    request({url: cloudantUri})
    .pipe(JSONStream.parse('counts.companyName')).on('data', (data) ->

      keys = []
      for k,v of data
        keys.push(k)

      keys.sort((a, b) -> data[b] - data[a])

      results = []
      for key in keys
        entity = rotateText(key.substring(0, key.indexOf(' ')), -325)
        name = key.substring(key.indexOf(' ') + 1, key.length)
        results.push({id: entity, value: unEscape(name)})

      if tickerLookup?
        results.unshift({id: "http://www.sec.gov/CIK/#{tickerLookup.cik}", value: unEscape(tickerLookup.name)})

      res.end(JSON.stringify(results))
    )
  )
)


module.exports = router