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

    @facts.push(fact)
    next()

  _flush: (next) ->

    factHash = {}
    for fact in @facts
      if not factHash[fact.GetHashValue()]
        factHash[fact.GetHashValue()] = fact
      else if factHash[fact.GetHashValue()].FilingDate < fact.FilingDate
        factHash[fact.GetHashValue()] = fact
      else if factHash[fact.GetHashValue()].FilingDate is fact.FilingDate and not factHash[fact.GetHashValue()].Amendment and fact.Amendment
        factHash[fact.GetHashValue()] = fact

    seriesCollection = {}
    for hash,fact of factHash
      seriesDescription = fact.GetSeriesDescription()
      if not seriesCollection[seriesDescription]? then seriesCollection[seriesDescription] = []
      seriesCollection[seriesDescription].push(fact)

    factHash = null
    seriesCollectionParsed = {}

    for seriesDescription, facts of seriesCollection

      #Sort by startDate ASC, endDate ASC
      facts.sort (a,b) -> a.GetSortValue(b)

      for fact in facts

        #Value may be nil, even if it wasn't declared so, we dont' need to worry about those facts
        if not fact.Value?
          continue;

        if not seriesCollectionParsed[seriesDescription]? then seriesCollectionParsed[seriesDescription] = {data: [], renderingData: {}}
        seriesCollectionParsed[seriesDescription].data.push([fact.EndDate.getTime(), fact.Value])
        seriesCollectionParsed[seriesDescription].renderingData["#{fact.EndDate.getTime()}--#{fact.Value}"] = {rendering: "https://www.sec.gov/cgi-bin/viewer?action=view&cik=#{fact.CIK}&accession_number=#{fact.AccesssionNumber}", xml: decodeURIComponent(fact.URL), unit: fact.GetUnitDescription()}

      seriesCollectionParsed[seriesDescription].shareKey = facts[0].GetSeriesKey()


    @push(seriesCollectionParsed)
    next()

#    _transform: (chunk, enc, next) ->
#
#    doc = chunk.doc
#
#    #determine if period is instant/annual/quarterly, if other then ignore
#    if (not doc.startDate?)
#      periodDescription = "instant"
#    else
#      parsedStartDate = new Date(doc.startDate);
#      parsedEndDate = new Date(doc.endDate);
#      day = 1000 * 60 * 60 * 24;
#
#      diff = Math.ceil((parsedEndDate.getTime() - parsedStartDate.getTime()) / day);
#
#      if (diff is 365 || diff is 364)
#        periodDescription = "annual"
#      else if (diff > 80 && diff < 100)
#        periodDescription = "quarterly"
#      else
#        return next()
#
#    #concatenate dimensions
#    dimensionsDescription = ''
#
#    if (doc.dimensions?)
#      for dimension in doc.dimensions
#        dimensionsDescription += dimension.axisName + '->' + dimension.memberName + '|'
#      dimensionsDescription = dimensionsDescription.substring(0, dimensionsDescription.length-1);
#
#    seriesDescription =  doc.entity + ":" + doc.conceptName + (if periodDescription is "instant" then "" else " -- " + periodDescription) + (if doc.dimensions? then " -- " + dimensionsDescription else "")
#    if not @seriesCollection[seriesDescription]? then @seriesCollection[seriesDescription] = []
#    @seriesCollection[seriesDescription].push({key: chunk.key, doc: doc})
#
#    next()
#
#  _flush: (next) ->
#
#    sortBy = (key, a, b, r) ->
#      r = if r then 1 else -1
#      return -1*r if a.doc[key] > b.doc[key]
#      return +1*r if a.doc[key] < b.doc[key]
#      return 0
#
#    for seriesDescription, facts of @seriesCollection
#
#      #Sort by startDate ASC, endDate ASC
#      facts.sort (a,b) ->
#        sortBy('endDate', a, b) or
#        sortBy('startDate', a, b)
#
#      useThisSet = true
#      #Ensure that if the data is quarterly, a gap of no more than a quarter exists between two data points
#      if (facts[0].key[2] is "quarterly" or facts[0].key[2] is "annual") and facts.length > 1
#        for count in [1..facts.length-1]
#
#          parsedPrevEndDate = new Date(facts[count-1].doc.endDate)
#          parsedEndDate = new Date(facts[count].doc.endDate)
#          day = 1000*60*60*24;
#          diff = Math.ceil((parsedEndDate.getTime()-parsedPrevEndDate.getTime())/(day));
#          if (facts[0].key[2] is "quarterly" and diff > 200) or (facts[0].key[2] is "annual" and diff > 370)
#            useThisSet = false
#
#      if useThisSet
#        for fact in facts
#
#          #Value may be nil, we dont' need to worry about those facts
#          if not fact.doc.value?
#            continue;
#
#          if not @seriesCollectionParsed[seriesDescription]? then @seriesCollectionParsed[seriesDescription] = {data: [], additionalData: {}}
#          ticks = new Date(fact.doc.endDate).getTime()
#          console.log(fact.doc.value)
#          value = JSON.parse(fact.doc.value)
#          @seriesCollectionParsed[seriesDescription].data.push([ticks, value]) if fact.doc.value?
#          filingRegexMatches = /www\.sec\.gov\/Archives\/edgar\/data\/([0-9]+)\/([0-9]+)\/.*/.exec(fact.doc.filing)
#          @seriesCollectionParsed[seriesDescription].additionalData["#{ticks}--#{value}"] = {rendering: "https://www.sec.gov/cgi-bin/viewer?action=view&cik=#{filingRegexMatches[1]}&accession_number=#{filingRegexMatches[2]}", xml: fact.doc.filing, unit: fact.doc.unit}
#
#
#    @push(@seriesCollectionParsed)
#    next()