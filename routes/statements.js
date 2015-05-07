// Generated by CoffeeScript 1.9.2
(function() {
  var FACTransformStream, JSONStream, express, getCloudantUrl, http, request, router, tickerResolver;

  express = require('express');

  http = require('http');

  request = require('request');

  JSONStream = require('JSONStream');

  tickerResolver = require('./helpers').tickerResolver;

  getCloudantUrl = require('./helpers').getCloudantUrl;

  FACTransformStream = require('../streams/FACTransformStream').FACTransformStream;

  router = express.Router();

  router.get('/statements', function(req, res) {
    return request({
      url: (getCloudantUrl()) + "/factsdev/_design/factsMainViews/_view/facs?keys=[\"http://www.sec.gov/CIK/0000051143\", \"http://www.sec.gov/CIK/0000789019\"]&include_docs=true&stale=update_after"
    }).pipe(JSONStream.parse('rows.*.doc')).pipe(new FACTransformStream(["http://www.sec.gov/CIK/0000051143", "http://www.sec.gov/CIK/0000789019"])).on('data', function(data) {
      data['entities'] = ['INTERNATIONAL BUSINESS MACHINES CORP', 'MICROSOFT CORP'];
      return res.render('statements', {
        pageData: data
      });
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=statements.js.map
