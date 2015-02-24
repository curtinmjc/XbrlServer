request = require('request')
express = require('express')
uuid = require('node-uuid')
router = express.Router()

router.post('/save', (req, res) ->

  if not req.body.sets? and not req.body.series?
    res.send(500)

  uuid = uuid.v4()
  options = {
    uri: 'https://<user>:<pass>@0741ae13-4f99-4ffb-8282-60d27e161c7f-bluemix.cloudant.com/share/'
    method: 'POST',
    json: {sets: req.body.sets, series: req.body.series, uuid: uuid},
    headers: { 'Content-type': 'application/json'}
  }

  request.post(options, (error, response, body) ->
    if (not error && response.statusCode is 201)
      res.end(uuid)
    else
      res.send(response.statusCode)
  )
)

module.exports = router