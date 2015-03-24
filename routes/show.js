// Generated by CoffeeScript 1.8.0
(function() {
  var async, express, getCloudantUrl, getParsedFactData, getParsedFactDataInternal, http, reduce, request, respondWithEmpty, router, unEscape;

  express = require('express');

  http = require('http');

  async = require('async');

  reduce = require("stream-reduce");

  request = require('request');

  router = express.Router();

  getParsedFactData = require('./helpers').getParsedFactData;

  unEscape = require('./helpers').unEscape;

  getCloudantUrl = require('./helpers').getCloudantUrl;

  getParsedFactDataInternal = function(set, callback) {
    return getParsedFactData(set.identifier, set.conceptName, function(data) {
      return callback(null, data);
    });
  };

  respondWithEmpty = function(res) {
    return res.render('index', {
      pageData: {
        facts: null,
        sets: [],
        series: {}
      }
    });
  };

  router.get(/\/show\/([a-zA-Z0-9\-]+)/, function(req, res) {
    var id, options;
    id = req.params[0];
    options = {
      uri: "" + (getCloudantUrl()) + "/share/_design/shareMainViews/_view/UUID?key=\"" + id + "\"&include_docs=true",
      method: 'GET'
    };
    return request.get(options, function(error, response, body) {
      var responseBody;
      if (!error && response.statusCode === 200) {
        responseBody = JSON.parse(body);
        if ((responseBody.rows == null) || responseBody.rows.length === 0) {
          return respondWithEmpty(res);
        }
        return async.map(responseBody.rows[0].doc.sets, getParsedFactDataInternal, function(err, results) {
          var concatResults, item, k, v, _i, _len;
          concatResults = {};
          for (_i = 0, _len = results.length; _i < _len; _i++) {
            item = results[_i];
            for (k in item) {
              v = item[k];
              concatResults[k] = v;
            }
          }
          return res.render('index', {
            pageData: {
              facts: concatResults,
              sets: responseBody.rows[0].doc.sets,
              series: responseBody.rows[0].doc.series
            }
          });
        });
      } else {
        return respondWithEmpty(res);
      }
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=show.js.map
