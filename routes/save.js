// Generated by CoffeeScript 1.8.0
(function() {
  var express, request, router, uuid;

  request = require('request');

  express = require('express');

  uuid = require('node-uuid');

  router = express.Router();

  router.post('/save', function(req, res) {
    var env, options;
    if ((req.body.sets == null) && (req.body.series == null)) {
      res.send(500);
    }
    console.log(process.env.VCAP_SERVICES);
    env = JSON.parse(process.env.VCAP_SERVICES);
    uuid = uuid.v4();
    options = {
      uri: "https://" + env['cloudantNoSQLDB'][0]['url'] + "/share/",
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
