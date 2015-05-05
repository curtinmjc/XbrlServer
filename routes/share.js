// Generated by CoffeeScript 1.9.2
(function() {
  var express, router;

  express = require('express');

  router = express.Router();

  router.get(/\/share\/([a-zA-Z0-9\-]+)/, function(req, res) {
    var id;
    id = req.params[0];
    return res.render('share', {
      pageData: {
        shareUrl: "http://xbrl-dev.mybluemix.net/show/" + id
      }
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=share.js.map
