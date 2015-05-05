express = require('express')
router = express.Router()

router.get(/\/share\/([a-zA-Z0-9\-]+)/, (req, res) ->

  id = req.params[0]
  res.render('share', {pageData: {shareUrl: "http://xbrl-dev.mybluemix.net/show/" + id}})
)

module.exports = router