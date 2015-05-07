{Fact} = require('../model/Fact')
stream = require('stream')

class exports.FACTransformStream extends stream.Transform

  constructor: (@entities) ->
    @bsFacts = {
      Assets:{},
      CurrentAssets:{},
      NoncurrentAssets:{},
      LiabilitiesAndEquity:{},
      Liabilities:{},
      CurrentLiabilities:{},
      NoncurrentLiabilities:{},
      CommitmentsAndContingencies:{},
      TemporaryEquity:{},
      RedeemableNoncontrollingInterest:{},
      Equity:{},
      EquityAttributableToNoncontrollingInterest:{},
      EquityAttributableToParent:{}
    }

    for entity in @entities
      @bsFacts.Assets[entity] = {}
      @bsFacts.CurrentAssets[entity] = {}
      @bsFacts.NoncurrentAssets[entity] = {}
      @bsFacts.LiabilitiesAndEquity[entity] = {}
      @bsFacts.Liabilities[entity] = {}
      @bsFacts.CurrentLiabilities[entity] = {}
      @bsFacts.NoncurrentLiabilities[entity] = {}
      @bsFacts.CommitmentsAndContingencies[entity] = {}
      @bsFacts.TemporaryEquity[entity] = {}
      @bsFacts.RedeemableNoncontrollingInterest[entity] = {}
      @bsFacts.Equity[entity] = {}
      @bsFacts.EquityAttributableToNoncontrollingInterest[entity] = {}
      @bsFacts.EquityAttributableToParent[entity] = {}


    @bsDates = {}
    super
      objectMode: true

  _transform: (chunk, enc, next) ->

    fact = new Fact(chunk)
    timeIndex = "#{fact.EndDate.getTime()}"
    switch fact.ElementName
      when 'fac:Assets' then @bsFacts.Assets[fact.Entity][timeIndex] = fact.Value
      when 'fac:CurrentAssets' then @bsFacts.CurrentAssets[fact.Entity][timeIndex] = fact.Value
      when 'fac:NoncurrentAssets' then @bsFacts.NoncurrentAssets[fact.Entity][timeIndex] = fact.Value
      when 'fac:LiabilitiesAndEquity' then @bsFacts.LiabilitiesAndEquity[fact.Entity][timeIndex] = fact.Value
      when 'fac:Liabilities' then @bsFacts.Liabilities[fact.Entity][timeIndex] = fact.Value
      when 'fac:CurrentLiabilities' then @bsFacts.CurrentLiabilities[fact.Entity][timeIndex] = fact.Value
      when 'fac:NoncurrentLiabilities' then @bsFacts.NoncurrentLiabilities[fact.Entity][timeIndex] = fact.Value
      when 'fac:CommitmentsAndContingencies' then @bsFacts.CommitmentsAndContingencies[fact.Entity][timeIndex] = fact.Value
      when 'fac:TemporaryEquity' then @bsFacts.TemporaryEquity[fact.Entity][timeIndex] = fact.Value
      when 'fac:RedeemableNoncontrollingInterest' then @bsFacts.RedeemableNoncontrollingInterest[fact.Entity][timeIndex] = fact.Value
      when 'fac:Equity' then @bsFacts.Equity[fact.Entity][timeIndex] = fact.Value
      when 'fac:EquityAttributableToNoncontrollingInterest' then @bsFacts.EquityAttributableToNoncontrollingInterest[fact.Entity][timeIndex] = fact.Value
      when 'fac:EquityAttributableToParent' then @bsFacts.EquityAttributableToParent[fact.Entity][timeIndex] = fact.Value

    @bsDates["#{fact.EndDate.getTime()}"] = fact.EndDate.getTime()

    next()

  _flush: (next) ->

    outputBsFacts = {}
    sortedBsDates = (new Date(v) for k, v of @bsDates)
    sortedBsDates.sort((a, b) ->
      if a > b
        return -1
      else if a < b
        return 1
      else
        return 0)



    outputBsDates = (value.getMonth()+1 + "/" + value.getDate() + "/" + value.getFullYear() for value in sortedBsDates)

    outputBsFacts = {
      Assets:[],
      CurrentAssets:[],
      NoncurrentAssets:[],
      LiabilitiesAndEquity:[],
      Liabilities:[],
      CurrentLiabilities:[],
      NoncurrentLiabilities:[],
      CommitmentsAndContingencies:[],
      TemporaryEquity:[],
      RedeemableNoncontrollingInterest:[],
      Equity:[],
      EquityAttributableToNoncontrollingInterest:[],
      EquityAttributableToParent:[]
    }

    for date in sortedBsDates
      for entity in @entities
        timeIndex = "#{date.getTime()}"
        outputBsFacts.Assets.push(if @bsFacts.Assets[entity][timeIndex]? then @bsFacts.Assets[entity][timeIndex] else null)
        outputBsFacts.CurrentAssets.push(if @bsFacts.CurrentAssets[entity][timeIndex]? then @bsFacts.CurrentAssets[entity][timeIndex] else null)
        outputBsFacts.NoncurrentAssets.push(if @bsFacts.NoncurrentAssets[entity][timeIndex]? then @bsFacts.NoncurrentAssets[entity][timeIndex] else null)
        outputBsFacts.LiabilitiesAndEquity.push(if @bsFacts.LiabilitiesAndEquity[entity][timeIndex]? then @bsFacts.LiabilitiesAndEquity[entity][timeIndex] else null)
        outputBsFacts.Liabilities.push(if @bsFacts.Liabilities[entity][timeIndex]? then @bsFacts.Liabilities[entity][timeIndex] else null)
        outputBsFacts.CurrentLiabilities.push(if @bsFacts.CurrentLiabilities[entity][timeIndex]? then @bsFacts.CurrentLiabilities[entity][timeIndex] else null)
        outputBsFacts.NoncurrentLiabilities.push(if @bsFacts.NoncurrentLiabilities[entity][timeIndex]? then @bsFacts.NoncurrentLiabilities[entity][timeIndex] else null)
        outputBsFacts.CommitmentsAndContingencies.push(if @bsFacts.CommitmentsAndContingencies[entity][timeIndex]? then @bsFacts.CommitmentsAndContingencies[entity][timeIndex] else null)
        outputBsFacts.TemporaryEquity.push(if @bsFacts.TemporaryEquity[entity][timeIndex]? then @bsFacts.TemporaryEquity[entity][timeIndex] else null)
        outputBsFacts.RedeemableNoncontrollingInterest.push(if @bsFacts.RedeemableNoncontrollingInterest[entity][timeIndex]? then @bsFacts.RedeemableNoncontrollingInterest[entity][timeIndex] else null)
        outputBsFacts.Equity.push(if @bsFacts.Equity[entity][timeIndex]? then @bsFacts.Equity[entity][timeIndex] else null)
        outputBsFacts.EquityAttributableToNoncontrollingInterest.push(if @bsFacts.EquityAttributableToNoncontrollingInterest[entity][timeIndex]? then @bsFacts.EquityAttributableToNoncontrollingInterest[entity][timeIndex] else null)
        outputBsFacts.EquityAttributableToParent.push(if @bsFacts.EquityAttributableToParent[entity][timeIndex]? then @bsFacts.EquityAttributableToParent[entity][timeIndex] else null)

    @push({bsDates: outputBsDates, bsFacts: outputBsFacts})
    next()
