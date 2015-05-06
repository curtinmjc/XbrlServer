{Fact} = require('../model/Fact')
stream = require('stream')

class exports.FACTransformStream extends stream.Transform

  constructor: () ->
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
    @bsDates = {}
    super
      objectMode: true

  _transform: (chunk, enc, next) ->

    fact = new Fact(chunk)
    timeIndex = "#{fact.EndDate.getTime()}"
    switch fact.ElementName
      when 'fac:Assets' then @bsFacts.Assets[timeIndex] = fact.Value
      when 'fac:CurrentAssets' then @bsFacts.CurrentAssets[timeIndex] = fact.Value
      when 'fac:NoncurrentAssets' then @bsFacts.NoncurrentAssets[timeIndex] = fact.Value
      when 'fac:LiabilitiesAndEquity' then @bsFacts.LiabilitiesAndEquity[timeIndex] = fact.Value
      when 'fac:Liabilities' then @bsFacts.Liabilities[timeIndex] = fact.Value
      when 'fac:CurrentLiabilities' then @bsFacts.CurrentLiabilities[timeIndex] = fact.Value
      when 'fac:NoncurrentLiabilities' then @bsFacts.NoncurrentLiabilities[timeIndex] = fact.Value
      when 'fac:CommitmentsAndContingencies' then @bsFacts.CommitmentsAndContingencies[timeIndex] = fact.Value
      when 'fac:TemporaryEquity' then @bsFacts.TemporaryEquity[timeIndex] = fact.Value
      when 'fac:RedeemableNoncontrollingInterest' then @bsFacts.RedeemableNoncontrollingInterest[timeIndex] = fact.Value
      when 'fac:Equity' then @bsFacts.Equity[timeIndex] = fact.Value
      when 'fac:EquityAttributableToNoncontrollingInterest' then @bsFacts.EquityAttributableToNoncontrollingInterest[timeIndex] = fact.Value
      when 'fac:EquityAttributableToParent' then @bsFacts.EquityAttributableToParent[timeIndex] = fact.Value

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
      timeIndex = "#{date.getTime()}"
      outputBsFacts.Assets.push(if @bsFacts.Assets[timeIndex]? then @bsFacts.Assets[timeIndex] else '&nbsp;')
      outputBsFacts.CurrentAssets.push(if @bsFacts.CurrentAssets[timeIndex]? then @bsFacts.CurrentAssets[timeIndex] else '&nbsp;')
      outputBsFacts.NoncurrentAssets.push(if @bsFacts.NoncurrentAssets[timeIndex]? then @bsFacts.NoncurrentAssets[timeIndex] else '&nbsp;')
      outputBsFacts.LiabilitiesAndEquity.push(if @bsFacts.LiabilitiesAndEquity[timeIndex]? then @bsFacts.LiabilitiesAndEquity[timeIndex] else '&nbsp;')
      outputBsFacts.Liabilities.push(if @bsFacts.Liabilities[timeIndex]? then @bsFacts.Liabilities[timeIndex] else '&nbsp;')
      outputBsFacts.CurrentLiabilities.push(if @bsFacts.CurrentLiabilities[timeIndex]? then @bsFacts.CurrentLiabilities[timeIndex] else '&nbsp;')
      outputBsFacts.NoncurrentLiabilities.push(if @bsFacts.NoncurrentLiabilities[timeIndex]? then @bsFacts.NoncurrentLiabilities[timeIndex] else '&nbsp;')
      outputBsFacts.CommitmentsAndContingencies.push(if @bsFacts.CommitmentsAndContingencies[timeIndex]? then @bsFacts.CommitmentsAndContingencies[timeIndex] else '&nbsp;')
      outputBsFacts.TemporaryEquity.push(if @bsFacts.TemporaryEquity[timeIndex]? then @bsFacts.TemporaryEquity[timeIndex] else '&nbsp;')
      outputBsFacts.RedeemableNoncontrollingInterest.push(if @bsFacts.RedeemableNoncontrollingInterest[timeIndex]? then @bsFacts.RedeemableNoncontrollingInterest[timeIndex] else '&nbsp;')
      outputBsFacts.Equity.push(if @bsFacts.Equity[timeIndex]? then @bsFacts.Equity[timeIndex] else '&nbsp;')
      outputBsFacts.EquityAttributableToNoncontrollingInterest.push(if @bsFacts.EquityAttributableToNoncontrollingInterest[timeIndex]? then @bsFacts.EquityAttributableToNoncontrollingInterest[timeIndex] else '&nbsp;')
      outputBsFacts.EquityAttributableToParent.push(if @bsFacts.EquityAttributableToParent[timeIndex]? then @bsFacts.EquityAttributableToParent[timeIndex] else '&nbsp;')

    @push({bsDates: outputBsDates, bsFacts: outputBsFacts})
    next()
