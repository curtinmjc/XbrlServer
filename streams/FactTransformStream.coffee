{Fact} = require('../model/Fact')
stream = require('stream')

class exports.FactTransformStream extends stream.Transform

  constructor: () ->
    @facts = []
    super
      objectMode: true

  _transform: (chunk, enc, next) ->

    fact = new Fact(chunk.doc)

    if fact.IsDuration and fact.GetPeriodDescription() is 'other' or fact.IsNil
      return next()

    hashValue = fact.GetHashValue()

    if not @facts[hashValue]
      @facts[hashValue] = fact
    else if @facts[hashValue].FilingDate < fact.FilingDate
      @facts[hashValue] = fact
    else if @facts[hashValue].FilingDate is fact.FilingDate and not @facts[hashValue].Amendment and fact.Amendment
      @facts[hashValue] = fact

    next()

  _flush: (next) ->

    seriesCollection = {}
    for hash,fact of @facts
      seriesDescription = fact.GetSeriesDescription()
      if not seriesCollection[seriesDescription]? then seriesCollection[seriesDescription] = []
      seriesCollection[seriesDescription].push(fact)

    seriesCollectionParsed = {}

    for seriesDescription, facts of seriesCollection

#Sort by startDate ASC, endDate ASC
      facts.sort (a,b) -> a.GetSortValue(b)

      for fact in facts

#Value may be nil, even if it wasn't declared so, we don't need to worry about those facts
        if not fact.Value?
          continue;

        if not seriesCollectionParsed[seriesDescription]? then seriesCollectionParsed[seriesDescription] = {data: [], renderingData: {}}
        seriesCollectionParsed[seriesDescription].data.push([fact.EndDate.getTime(), fact.Value])
        seriesCollectionParsed[seriesDescription].renderingData["#{fact.EndDate.getTime()}--#{fact.Value}"] = {rendering: "https://www.sec.gov/cgi-bin/viewer?action=view&cik=#{fact.CIK}&accession_number=#{fact.AccesssionNumber}", xml: decodeURIComponent(fact.URL), unit: fact.GetUnitDescription()}

      seriesCollectionParsed[seriesDescription].shareKey = facts[0].GetSeriesKey()


    @push(seriesCollectionParsed)
    next()