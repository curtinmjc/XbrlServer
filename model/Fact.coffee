class exports.Fact
  constructor: (@doc) ->
    @IsDuration = @doc['http://www.xbrl.org/2003/instance/Period'].indexOf('--') >= 0
    @IsNil = JSON.parse(@doc["http://www.w3.org/2001/XMLSchema-instance/nil"])
    @StartDate = if @IsDuration then new Date(@doc['http://www.xbrl.org/2003/instance/Period'].split('--')[0]) else new Date(@doc['http://www.xbrl.org/2003/instance/Period'])
    @EndDate = if @IsDuration then new Date(@doc['http://www.xbrl.org/2003/instance/Period'].split('--')[1]) else new Date(@doc['http://www.xbrl.org/2003/instance/Period'])
    @FilingDate = new Date(@doc['http://www.sec.gov/Archives/edgar/filingDate'])
    @Amendment = JSON.parse(@doc['http://xbrl.sec.gov/Amendment'])
    @Value = JSON.parse(@doc['http://www.xbrl.org/2003/instance/Value'])
    @CIK = @doc['http://www.xbrl.org/2003/instance/Entity'].substring(@doc['http://www.xbrl.org/2003/instance/Entity'].lastIndexOf('/')+1, @doc['http://www.xbrl.org/2003/instance/Entity'].length)
    @URL = @doc['http://www.sec.gov/Archives/edgar/url']
    @AccesssionNumber = @doc['http://www.sec.gov/Archives/edgar/accessionNumber']

  getValue: (fqn) ->
    return fqn.substring(fqn.lastIndexOf("/") + 1, fqn.length)

  getElementName: (fqn) ->
    namespace = fqn.substring(0, fqn.lastIndexOf("/"))
    prefix = null

    switch namespace
      when 'http://www.xbrl.org/us/fr/common/pte/2005-02-28' then prefix = "usgaap"
      when 'http://xbrl.us/us-gaap/2008-01-31' then prefix = "usgaap"
      when 'http://xbrl.us/us-gaap/2009-01-31' then prefix = "usgaap"
      when 'http://fasb.org/us-gaap/2011-01-31' then prefix = "usgaap"
      when 'http://fasb.org/us-gaap/2012-01-31' then prefix = "usgaap"
      when 'http://fasb.org/us-gaap/2013-01-31' then prefix = "usgaap"
      when 'http://fasb.org/us-gaap/2014-01-31' then prefix = "usgaap"
      when 'http://fasb.org/us-gaap/2015-01-31' then prefix = "usgaap"
      when 'http://xbrl.sec.gov/dei/2014-01-31' then prefix = "dei"
      when 'http://xbrl.sec.gov/dei/2013-01-31' then prefix = "dei"
      when 'http://xbrl.sec.gov/dei/2012-01-31' then prefix = "dei"
      when 'http://xbrl.sec.gov/dei/2011-01-31' then prefix = "dei"
      when 'http://xbrl.us/dei/2009-01-31' then prefix = "dei"
      when 'http://xbrl.us/dei/2008-03-31' then prefix = "dei"
      when 'http://www.xbrlsite.com/fac' then prefix = "fac"
      else prefix = "ext"

    return "#{prefix}:#{@getValue(fqn)}"

  GetUnitDescription: ->
    if @unitDescription?
      return @unitDescription

    @unitDescription = ''
    if @doc['http://www.xbrl.org/2003/instance/Unit']['http://www.xbrl.org/2003/instance/unitNumerator']?
      for numerator in @doc['http://www.xbrl.org/2003/instance/Unit']['http://www.xbrl.org/2003/instance/unitNumerator']
        @unitDescription += @getValue(numerator) + '*'
      @unitDescription = @unitDescription.substring(0, @unitDescription.length-1);

      if @doc['http://www.xbrl.org/2003/instance/Unit']['http://www.xbrl.org/2003/instance/unitDenominator']?
        @unitDescription += '/'
        for denominator in @doc['http://www.xbrl.org/2003/instance/Unit']['http://www.xbrl.org/2003/instance/unitDenominator']
          @unitDescription += @getValue(denominator) + '*'
        @unitDescription = @unitDescription.substring(0, @unitDescription.length-1);
    else
      @unitDescription = @getValue(@doc['http://www.xbrl.org/2003/instance/Unit'])

    return @unitDescription

  GetDimensions: ->
    if @dimensions?
      return @dimenions

    @dimensions = {}
    for k,v of @doc
      if k isnt "http://www.xbrl.org/2003/instance/Entity" and
        k isnt "http://www.xbrl.org/2003/instance/Concept" and
        k isnt "http://www.xbrl.org/2003/instance/Period" and
        k isnt "http://www.xbrl.org/2003/instance/Unit" and
        k isnt "http://www.w3.org/2001/XMLSchema-instance/nil" and
        k isnt "http://www.xbrl.org/2003/instance/Value" and
        k isnt "http://www.xbrl.org/2003/instance/Decimals" and
        k isnt "http://www.xbrl.org/2003/instance/Precision" and
        k isnt "http://www.sec.gov/Archives/edgar/companyName" and
        k isnt "http://www.sec.gov/Archives/edgar/filingDate" and
        k isnt "http://www.sec.gov/Archives/edgar/accessionNumber" and
        k isnt "http://www.sec.gov/Archives/edgar/fileNumber" and
        k isnt "http://www.sec.gov/Archives/edgar/url" and
        k isnt "http://xbrl.sec.gov/Amendment" and
        k isnt "http://xbrl.sec.gov/FiscalYear" and
        k isnt "http://xbrl.sec.gov/FiscalPeriod" and
        k isnt "_id" and
        k isnt "_rev"
          @dimensions[k] = v
    return @dimensions

  GetHashValue: ->
    if @hashValue?
      return @hashValue

    hashValues = []
    for k,v of @doc
      if k isnt "http://www.w3.org/2001/XMLSchema-instance/nil" and
        k isnt "http://www.xbrl.org/2003/instance/Value" and
        k isnt "http://www.xbrl.org/2003/instance/Decimals" and
        k isnt "http://www.xbrl.org/2003/instance/Precision" and
        k isnt "http://www.sec.gov/Archives/edgar/companyName" and
        k isnt "http://www.sec.gov/Archives/edgar/filingDate" and
        k isnt "http://www.sec.gov/Archives/edgar/accessionNumber" and
        k isnt "http://www.sec.gov/Archives/edgar/fileNumber" and
        k isnt "http://www.sec.gov/Archives/edgar/url" and
        k isnt "http://xbrl.sec.gov/Amendment" and
        k isnt "http://xbrl.sec.gov/FiscalYear" and
        k isnt "http://xbrl.sec.gov/FiscalPeriod" and
        k isnt "_id" and
        k isnt "_rev"
          hashValues.push(v)

    @hashValue = ''
    hashValues.sort()
    for value in hashValues
      @hashValue += value

    return @hashValue

  GetPeriodDescription: ->
    if @periodDescription?
      return @periodDescription

    diff = Math.ceil((@EndDate.getTime() - @StartDate.getTime()) / 86400000);

    if (diff is 365 || diff is 364)
      @periodDescription = "annual"
    else if (diff > 80 && diff < 100)
      @periodDescription = "quarterly"
    else
      @periodDescription = "other"

    return @periodDescription

  GetDimensionsDescription: ->

    if @dimensionsDescription?
      return @dimensionsDescription

    @dimensionsDescription = ''
    for k,v of @GetDimensions()
      @dimensionsDescription += @getValue(k) + '->' + @getValue(v) + '<br/>'
    @dimensionsDescription = @dimensionsDescription.substring(0, @dimensionsDescription.length-5);
    return @dimensionsDescription

  GetSeriesDescription: ->
    if @seriesDescription?
      return @seriesDescription

    @seriesDescription = '[' + @doc['http://www.sec.gov/Archives/edgar/companyName'] + "]:" + @getElementName(@doc['http://www.xbrl.org/2003/instance/Concept']) + (if not @IsDuration then "" else " -- " + @GetPeriodDescription()) + (if @GetDimensionsDescription() isnt '' then "<br/>" + @GetDimensionsDescription() else "")
    return @seriesDescription

  GetSeriesKey: ->
    if @seriesKey?
      return @seriesKey

    @seriesKey = @doc['http://www.xbrl.org/2003/instance/Entity'] + ":" + @getElementName(@doc['http://www.xbrl.org/2003/instance/Concept']) + (if not @IsDuration then "" else " -- " + @GetPeriodDescription()) + (if @GetDimensionsDescription() isnt '' then " -- " + @GetDimensionsDescription() else "")
    return @seriesKey

  GetSortValue: (OtherFact) ->
    return -1 if @EndDate < OtherFact.EndDate
    return 1 if @EndDate > OtherFact.EndDate
    return 0
