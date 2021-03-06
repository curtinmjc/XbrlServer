// Generated by CoffeeScript 1.9.2
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
    cloudantUri = (getCloudantUrl()) + "/facts/_design/factsMainSearchIndexes/_search/EntitySplitConcept?q=entity:\"" + identifier + "\"%20AND%20conceptNameSplit:" + term + "&counts=[\"conceptNameSplit\"]&limit=0";
    return request({
      url: cloudantUri
    }).pipe(JSONStream.parse('counts.conceptNameSplit')).on('data', function(data) {
      var i, j, k, keys, ref, v;
      keys = [];
      for (k in data) {
        v = data[k];
        keys.push(k);
      }
      keys.sort(function(a, b) {
        return data[b] - data[a];
      });
      if (keys.length > 0) {
        for (i = j = 0, ref = keys.length - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          keys[i] = keys[i].replace(/\s/g, "");
        }
      }
      return res.end(JSON.stringify(keys));
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=elements.js.map
