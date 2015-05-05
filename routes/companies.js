// Generated by CoffeeScript 1.9.2
(function() {
  var JSONStream, express, getCloudantUrl, recursiveCloudantSearch, request, rotateText, router, tickerResolver, unEscape;

  express = require('express');

  tickerResolver = require('./helpers').tickerResolver;

  recursiveCloudantSearch = require('./helpers').recursiveCloudantSearch;

  unEscape = require('./helpers').unEscape;

  getCloudantUrl = require('./helpers').getCloudantUrl;

  JSONStream = require('JSONStream');

  request = require('request');

  router = express.Router();

  rotateText = function(text, rotation) {
    var bound;
    bound = 0x10000;
    rotation = parseInt(rotation) % bound;
    if (rotation === 0) {
      return text;
    }
    return String.fromCharCode.apply(null, text.split('').map(function(v) {
      return (v.charCodeAt() + rotation + bound) % bound;
    }));
  };

  router.get(/\/companies/, function(req, res) {
    var term;
    term = req.query.term;
    return tickerResolver(term, function(tickerLookup) {
      var cloudantUri;
      cloudantUri = (getCloudantUrl()) + "/factsdev/_design/factsMainSearchIndexes/_search/EntityCipherCompanyName?q=companyName:" + term + "&counts=[\"companyName\"]&limit=0";
      return request({
        url: cloudantUri
      }).pipe(JSONStream.parse('counts.companyName')).on('data', function(data) {
        var entity, i, k, key, keys, len, name, results, v;
        keys = [];
        for (k in data) {
          v = data[k];
          keys.push(k);
        }
        keys.sort(function(a, b) {
          return data[b] - data[a];
        });
        results = [];
        for (i = 0, len = keys.length; i < len; i++) {
          key = keys[i];
          entity = rotateText(key.substring(0, key.indexOf(' ')), -325);
          name = key.substring(key.indexOf(' ') + 1, key.length);
          results.push({
            id: entity,
            value: unEscape(name)
          });
        }
        if (tickerLookup != null) {
          results.unshift({
            id: "http://www.sec.gov/CIK/" + tickerLookup.cik,
            value: unEscape(tickerLookup.name)
          });
        }
        return res.end(JSON.stringify(results));
      });
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=companies.js.map
