express = require('express')
{getParsedFactData} = require('./helpers')

router = express.Router()

#router.get(/\/facts\/([0-9]{10})\/(.+)/, (req, res) ->
#  identifier = req.params[0]
#  elementName = req.params[1]
#
#  getParsedFactData(identifier, elementName, (data) -> res.end(JSON.stringify(data)))
#
#)

router.get(/\/facts/, (req, res) ->
  identifier = req.query.identifier
  conceptName = req.query.conceptName


  getParsedFactData(identifier, conceptName, (data) -> res.end(JSON.stringify(data)))

)

module.exports = router