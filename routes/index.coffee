express = require('express')
router = express.Router()

router.get('/', (req, res) ->

#  ua = req.header('user-agent')
#  if(/mobile/i.test(ua))
#    res.render('m/index');
#  else
    res.render('index', {pageData: {facts: null, sets: [], series: {}, friendlyNames: {}}})
)

module.exports = router