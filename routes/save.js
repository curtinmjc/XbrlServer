// Generated by CoffeeScript 1.9.2
(function() {
  var express, getCloudantUrl, request, router, uuid;

  request = require('request');

  express = require('express');

  uuid = require('node-uuid');

  getCloudantUrl = require('./helpers').getCloudantUrl;

  router = express.Router();

  router.post('/save', function(req, res) {
    var options;
    if ((req.body.sets == null) && (req.body.series == null)) {
      res.send(500);
    }
    uuid = uuid.v4();
    options = {
      uri: (getCloudantUrl()) + "/share/",
      method: 'POST',
      json: {
        sets: req.body.sets,
        series: req.body.series,
        uuid: uuid
      },
      headers: {
        'Content-type': 'application/json'
      }
    };
    return request.post(options, function(error, response, body) {
      if (!error && response.statusCode === 201) {
        return res.end(uuid);
      } else {
        return res.send(response);
      }
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=save.js.map
