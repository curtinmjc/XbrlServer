express = require('express')
http = require('http')
request = require('request')
JSONStream = require('JSONStream')
{tickerResolver} = require('./helpers')
{getCloudantUrl} = require('./helpers')
{FACTransformStream} = require('../streams/FACTransformStream')
router = express.Router()

router.get('/statements', (req, res) ->

#  ua = req.header('user-agent')
#  if(/mobile/i.test(ua))
#    res.render('m/index');
#  else

  request({url: "#{getCloudantUrl()}/factsdev/_design/factsMainViews/_view/facs?keys=[\"http://www.sec.gov/CIK/0000051143\", \"http://www.sec.gov/CIK/0000789019\"]&include_docs=true&stale=update_after"})
  .pipe(JSONStream.parse('rows.*.doc'))
  .pipe(new FACTransformStream(["http://www.sec.gov/CIK/0000051143", "http://www.sec.gov/CIK/0000789019"]))
  .on('data', (data) ->
    data['entities'] = ['INTERNATIONAL BUSINESS MACHINES CORP', 'MICROSOFT CORP']
    res.render('statements', {pageData: data})
  )
)

module.exports = router