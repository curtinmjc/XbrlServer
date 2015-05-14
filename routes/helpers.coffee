http = require('http')
reduce = require("stream-reduce")
JSONStream = require('JSONStream')
request = require('request')
require('date-utils');

getCloudantUrl = () ->
  env = JSON.parse(process.env.VCAP_SERVICES)
  return env['cloudantNoSQLDB'][0]['credentials']['url']

unEscape = (value) ->
  return value.replace('&amp;', '&')

recursiveCloudantSearch = (designDocUri, query, keySelector, valueSelector, bookmark, index, limit, callback) ->

  {BookmarkExtractorStream} = require('../streams/BookmarkExtractorStream')
  {UniqueArrayWriteStream} = require('../streams/UniqueArrayWriteStream')

  readUrl = "#{designDocUri}?q=#{query}&limit=200"
  oldBookmarkValue = bookmark.value
  if oldBookmarkValue?
    readUrl += "&bookmark=#{oldBookmarkValue}"

  request({url: readUrl})
  .pipe(new BookmarkExtractorStream(bookmark))
  .pipe(JSONStream.parse('rows.*.fields'))
  .pipe(new UniqueArrayWriteStream(index, keySelector, valueSelector, limit)).on('finish', ->
    if (bookmark.value isnt oldBookmarkValue and Object.keys(index).length < limit)
      recursiveCloudantSearch(designDocUri, query, keySelector, valueSelector, bookmark, index, limit, callback)
    else
      callback()
  )

getParsedFactData = (identifier, elementName, callback) ->

  cloudantFactsUri = "#{getCloudantUrl()}/factsdev/_design/factsMainViews/_view/EntityConceptName?key=[\"#{identifier}\",\"#{elementName}\"]&include_docs=true&stale=update_after&reduce=false"
  {FactTransformStream} = require('../streams/FactTransformStream')

  request({url: cloudantFactsUri})
  .pipe(JSONStream.parse('rows.*'))
  .pipe(new FactTransformStream()).on('data', (result) ->
    callback(result)
  )

tickerResolver = (ticker, callback) ->
  http.get("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{ticker}&count=1&output=xml", (httpReadStream) ->
    httpReadStream.pipe(reduce(((acc, data) ->
      acc = acc + data
      return acc), ''))
    .on('data', (cikSearchData) ->
      cikMatch = cikSearchData.match(/<CIK>([0-9]{10})<\/CIK>/)
      nameMatch = cikSearchData.match(/<name>([^<]+)<\/name>/)
      if cikMatch?
        cik = cikMatch[1]
        callback({cik: cik, name: nameMatch[1]})
      else
        callback(null)
    )
  )


module.exports = { recursiveCloudantSearch: recursiveCloudantSearch, tickerResolver: tickerResolver, getParsedFactData: getParsedFactData, unEscape: unEscape, getCloudantUrl: getCloudantUrl }