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
  reqEntities = ("\"#{entity}\"" for entity in req.body.entities).join()
  request({url: "#{getCloudantUrl()}/factsdev/_design/factsMainViews/_view/FACEntity?keys=[#{reqEntities}]&include_docs=true&stale=update_after"})
  .pipe(JSONStream.parse('rows.*.doc'))
  .pipe(new FACTransformStream(req.body.entities))
  .on('data', (data) ->
    data['entities'] = ['INTERNATIONAL BUSINESS MACHINES CORP', 'MICROSOFT CORP']
    res.end(JSON.stringify(data))
  )
)

module.exports = router
