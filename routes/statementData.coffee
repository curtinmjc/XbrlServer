express = require('express')
http = require('http')
request = require('request')
JSONStream = require('JSONStream')
{tickerResolver} = require('./helpers')
{getCloudantUrl} = require('./helpers')
{FACTransformStream} = require('../streams/FACTransformStream')
router = express.Router()

router.post('/statementData', (req, res) ->

  if not req.body.entities?
    res.send(500)

  request({url: "#{getCloudantUrl()}/factsdev/_design/factsMainViews/_view/FACEntity?keys=[\"http://www.sec.gov/CIK/0000051143\", \"http://www.sec.gov/CIK/0000789019\"]&include_docs=true&stale=update_after"})
  .pipe(JSONStream.parse('rows.*.doc'))
  .pipe(new FACTransformStream(["http://www.sec.gov/CIK/0000051143", "http://www.sec.gov/CIK/0000789019"]))
  .on('data', (data) ->
    data['entities'] = ['INTERNATIONAL BUSINESS MACHINES CORP', 'MICROSOFT CORP']
    res.end(JSON.stringify(data))
  )
)

module.exports = router
