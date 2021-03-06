// Generated by CoffeeScript 1.9.2
(function() {
  var JSONStream, getCloudantUrl, getParsedFactData, http, recursiveCloudantSearch, reduce, request, tickerResolver, unEscape;

  http = require('http');

  reduce = require("stream-reduce");

  JSONStream = require('JSONStream');

  request = require('request');

  require('date-utils');

  getCloudantUrl = function() {
    var env;
    env = JSON.parse(process.env.VCAP_SERVICES);
    return env['cloudantNoSQLDB'][0]['credentials']['url'];
  };

  unEscape = function(value) {
    return value.replace('&amp;', '&');
  };

  recursiveCloudantSearch = function(designDocUri, query, keySelector, valueSelector, bookmark, index, limit, callback) {
    var BookmarkExtractorStream, UniqueArrayWriteStream, oldBookmarkValue, readUrl;
    BookmarkExtractorStream = require('../streams/BookmarkExtractorStream').BookmarkExtractorStream;
    UniqueArrayWriteStream = require('../streams/UniqueArrayWriteStream').UniqueArrayWriteStream;
    readUrl = designDocUri + "?q=" + query + "&limit=200";
    oldBookmarkValue = bookmark.value;
    if (oldBookmarkValue != null) {
      readUrl += "&bookmark=" + oldBookmarkValue;
    }
    return request({
      url: readUrl
    }).pipe(new BookmarkExtractorStream(bookmark)).pipe(JSONStream.parse('rows.*.fields')).pipe(new UniqueArrayWriteStream(index, keySelector, valueSelector, limit)).on('finish', function() {
      if (bookmark.value !== oldBookmarkValue && Object.keys(index).length < limit) {
        return recursiveCloudantSearch(designDocUri, query, keySelector, valueSelector, bookmark, index, limit, callback);
      } else {
        return callback();
      }
    });
  };

  getParsedFactData = function(identifier, elementName, callback) {
    var FactTransformStream, cloudantFactsUri;
    cloudantFactsUri = (getCloudantUrl()) + "/facts/_design/factsMainViews/_view/EntityConceptName?key=[\"" + identifier + "\",\"" + elementName + "\"]&include_docs=true&stale=update_after&reduce=false";
    FactTransformStream = require('../streams/FactTransformStream').FactTransformStream;
    return request({
      url: cloudantFactsUri
    }).pipe(JSONStream.parse('rows.*')).pipe(new FactTransformStream()).on('data', function(result) {
      return callback(result);
    });
  };

  tickerResolver = function(ticker, callback) {
    return http.get("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=" + ticker + "&count=1&output=xml", function(httpReadStream) {
      return httpReadStream.pipe(reduce((function(acc, data) {
        acc = acc + data;
        return acc;
      }), '')).on('data', function(cikSearchData) {
        var cik, cikMatch, nameMatch;
        cikMatch = cikSearchData.match(/<CIK>([0-9]{10})<\/CIK>/);
        nameMatch = cikSearchData.match(/<name>([^<]+)<\/name>/);
        if (cikMatch != null) {
          cik = cikMatch[1];
          return callback({
            cik: cik,
            name: nameMatch[1]
          });
        } else {
          return callback(null);
        }
      });
    });
  };

  module.exports = {
    recursiveCloudantSearch: recursiveCloudantSearch,
    tickerResolver: tickerResolver,
    getParsedFactData: getParsedFactData,
    unEscape: unEscape,
    getCloudantUrl: getCloudantUrl
  };

}).call(this);

//# sourceMappingURL=helpers.js.map
