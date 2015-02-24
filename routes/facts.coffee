express = require('express')
{getParsedFactData} = require('./helpers')

router = express.Router()

router.get(/\/facts/, (req, res) ->
  identifier = req.query.identifier
  conceptName = req.query.conceptName

  getParsedFactData(identifier, conceptName, (data) -> res.end(JSON.stringify(data)))

)

module.exports = router