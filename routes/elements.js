// Generated by CoffeeScript 1.8.0
(function() {
  var JSONStream, express, getCloudantUrl, request, router;

  express = require('express');

  JSONStream = require('JSONStream');

  request = require('request');

  getCloudantUrl = require('./helpers').getCloudantUrl;

  router = express.Router();

  router.get(/\/elements/, function(req, res) {
    var cloudantUri, identifier, term;
    identifier = req.query.identifier;
    term = req.query.term;
    cloudantUri = "" + (getCloudantUrl()) + "/facts/_design/factsMainSearchIndexes/_search/EntitySplitConcept?q=entity:\"" + identifier + "\"%20AND%20conceptNameSplit:" + term + "&counts=[\"conceptNameSplit\"]&limit=0";
    return request({
      url: cloudantUri
    }).pipe(JSONStream.parse('counts.conceptNameSplit')).on('data', function(data) {
      var i, k, keys, v, _i, _ref;
      keys = [];
      for (k in data) {
        v = data[k];
        keys.push(k);
      }
      keys.sort(function(a, b) {
        return data[b] - data[a];
      });
      if (keys.length > 0) {
        for (i = _i = 0, _ref = keys.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          keys[i] = keys[i].replace(/\s/g, "");
        }
      }
      return res.end(JSON.stringify(keys));
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=elements.js.map