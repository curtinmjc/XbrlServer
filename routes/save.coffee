request = require('request')
express = require('express')
uuid = require('node-uuid')
router = express.Router()

router.post('/save', (req, res) ->

  if not req.body.sets? and not req.body.series?
    res.send(500)

  env = JSON.parse(process.env.VCAP_SERVICES)
  uuid = uuid.v4()
  options = {
    uri: "https://#{env['cloudantNoSQLDB'][0].url}/share/"
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