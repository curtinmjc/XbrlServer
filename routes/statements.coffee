module.exports = router


express = require('express')
router = express.Router()

router.get('/statements', (req, res) ->

  res.render('statements')
)

module.exports = router