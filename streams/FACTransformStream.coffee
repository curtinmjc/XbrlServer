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

    @isFacts = {
      Revenues:{},
      CostOfRevenue:{},
      GrossProfit:{},
      OperatingExpenses:{},
      CostsAndExpenses:{},
      OtherOperatingIncomeExpenses:{},
      OperatingIncomeLoss:{},
      NonoperatingIncomeLoss:{},
      InterestAndDebtExpense:{},
      IncomeLossBeforeEquityMethodInvestments:{},
      IncomeLossFromEquityMethodInvestments:{},
      IncomeLossFromContinuingOperationsBeforeTax:{},
      IncomeTaxExpenseBenefit:{},
      IncomeLossFromContinuingOperationsAfterTax:{},
      IncomeLossFromDiscontinuedOperationsNetOfTax:{},
      ExtraordinaryItemsOfIncomeExpenseNetOfTax:{},
      NetIncomeLoss:{},
      NetIncomeLossAvailableToCommonStockholdersBasic:{},
      PreferredStockDividendsAndOtherAdjustments:{},
      NetIncomeLossAttributableToNoncontrollingInterest:{},
      NetIncomeLossAttributableToParent:{},
      OtherComprehensiveIncomeLoss:{},
      ComprehensiveIncomeLoss:{},
      ComprehensiveIncomeLossAttributableToParent:{},
      ComprehensiveIncomeLossAttributableToNoncontrollingInterest:{}
    }

    @cfFacts = {
      NetCashFlow:{},
      NetCashFlowFromOperatingActivities:{},
      NetCashFlowFromInvestingActivities:{},
      NetCashFlowFromFinancingActivities:{},
      NetCashFlowFromOperatingActivitiesContinuing:{},
      NetCashFlowFromInvestingActivitiesContinuing:{},
      NetCashFlowFromFinancingActivitiesContinuing:{},
      NetCashFlowFromOperatingActivitiesDiscontinued:{},
      NetCashFlowFromInvestingActivitiesDiscontinued:{},
      NetCashFlowFromFinancingActivitiesDiscontinued:{},
      NetCashFlowContinuing:{},
      NetCashFlowDiscontinued:{},
      ExchangeGainsLosses:{}
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

      @isFacts.Revenues[entity] = {}
      @isFacts.CostOfRevenue[entity] = {}
      @isFacts.GrossProfit[entity] = {}
      @isFacts.OperatingExpenses[entity] = {}
      @isFacts.CostsAndExpenses[entity] = {}
      @isFacts.OtherOperatingIncomeExpenses[entity] = {}
      @isFacts.OperatingIncomeLoss[entity] = {}
      @isFacts.NonoperatingIncomeLoss[entity] = {}
      @isFacts.InterestAndDebtExpense[entity] = {}
      @isFacts.IncomeLossBeforeEquityMethodInvestments[entity] = {}
      @isFacts.IncomeLossFromEquityMethodInvestments[entity] = {}
      @isFacts.IncomeLossFromContinuingOperationsBeforeTax[entity] = {}
      @isFacts.IncomeTaxExpenseBenefit[entity] = {}
      @isFacts.IncomeLossFromContinuingOperationsAfterTax[entity] = {}
      @isFacts.IncomeLossFromDiscontinuedOperationsNetOfTax[entity] = {}
      @isFacts.ExtraordinaryItemsOfIncomeExpenseNetOfTax[entity] = {}
      @isFacts.NetIncomeLoss[entity] = {}
      @isFacts.NetIncomeLossAvailableToCommonStockholdersBasic[entity] = {}
      @isFacts.PreferredStockDividendsAndOtherAdjustments[entity] = {}
      @isFacts.NetIncomeLossAttributableToNoncontrollingInterest[entity] = {}
      @isFacts.NetIncomeLossAttributableToParent[entity] = {}
      @isFacts.OtherComprehensiveIncomeLoss[entity] = {}
      @isFacts.ComprehensiveIncomeLoss[entity] = {}
      @isFacts.ComprehensiveIncomeLossAttributableToParent[entity] = {}
      @isFacts.ComprehensiveIncomeLossAttributableToNoncontrollingInterest[entity] = {}

      @cfFacts.NetCashFlow[entity] = {}
      @cfFacts.NetCashFlowFromOperatingActivities[entity] = {}
      @cfFacts.NetCashFlowFromInvestingActivities[entity] = {}
      @cfFacts.NetCashFlowFromFinancingActivities[entity] = {}
      @cfFacts.NetCashFlowFromOperatingActivitiesContinuing[entity] = {}
      @cfFacts.NetCashFlowFromInvestingActivitiesContinuing[entity] = {}
      @cfFacts.NetCashFlowFromFinancingActivitiesContinuing[entity] = {}
      @cfFacts.NetCashFlowFromOperatingActivitiesDiscontinued[entity] = {}
      @cfFacts.NetCashFlowFromInvestingActivitiesDiscontinued[entity] = {}
      @cfFacts.NetCashFlowFromFinancingActivitiesDiscontinued[entity] = {}
      @cfFacts.NetCashFlowContinuing[entity] = {}
      @cfFacts.NetCashFlowDiscontinued[entity] = {}
      @cfFacts.ExchangeGainsLosses[entity] = {}


    @instantDates = {}
    @durationDates = {}
    super
      objectMode: true

  chooseFact: (fact1, fact2) ->
    if not fact1?
      return fact2
    else if fact1.FilingDate < fact2.FilingDate
      return fact2
    else if fact1.FilingDate is fact2.FilingDate and not fact1.Amendment and fact2.Amendment
      return fact2
    else
      return fact1

  _transform: (chunk, enc, next) ->

    fact = new Fact(chunk)

    if not fact.FiscalPeriod?
      return next()

    timeIndex = fact.FiscalPeriod
    switch fact.ElementName
      when 'fac:Assets' then @bsFacts.Assets[fact.Entity][timeIndex] = @chooseFact(@bsFacts.Assets[fact.Entity][timeIndex], fact)
      when 'fac:CurrentAssets' then @bsFacts.CurrentAssets[fact.Entity][timeIndex] = @chooseFact(@bsFacts.CurrentAssets[fact.Entity][timeIndex], fact)
      when 'fac:NoncurrentAssets' then @bsFacts.NoncurrentAssets[fact.Entity][timeIndex] = @chooseFact(@bsFacts.NoncurrentAssets[fact.Entity][timeIndex], fact)
      when 'fac:LiabilitiesAndEquity' then @bsFacts.LiabilitiesAndEquity[fact.Entity][timeIndex] = @chooseFact(@bsFacts.LiabilitiesAndEquity[fact.Entity][timeIndex], fact)
      when 'fac:Liabilities' then @bsFacts.Liabilities[fact.Entity][timeIndex] = @chooseFact(@bsFacts.Liabilities[fact.Entity][timeIndex], fact)
      when 'fac:CurrentLiabilities' then @bsFacts.CurrentLiabilities[fact.Entity][timeIndex] = @chooseFact(@bsFacts.CurrentLiabilities[fact.Entity][timeIndex], fact)
      when 'fac:NoncurrentLiabilities' then @bsFacts.NoncurrentLiabilities[fact.Entity][timeIndex] = @chooseFact(@bsFacts.NoncurrentLiabilities[fact.Entity][timeIndex], fact)
      when 'fac:CommitmentsAndContingencies' then @bsFacts.CommitmentsAndContingencies[fact.Entity][timeIndex] = @chooseFact(@bsFacts.CommitmentsAndContingencies[fact.Entity][timeIndex], fact)
      when 'fac:TemporaryEquity' then @bsFacts.TemporaryEquity[fact.Entity][timeIndex] = @chooseFact(@bsFacts.TemporaryEquity[fact.Entity][timeIndex], fact)
      when 'fac:RedeemableNoncontrollingInterest' then @bsFacts.RedeemableNoncontrollingInterest[fact.Entity][timeIndex] = @chooseFact(@bsFacts.RedeemableNoncontrollingInterest[fact.Entity][timeIndex], fact)
      when 'fac:Equity' then @bsFacts.Equity[fact.Entity][timeIndex] = @chooseFact(@bsFacts.Equity[fact.Entity][timeIndex], fact)
      when 'fac:EquityAttributableToNoncontrollingInterest' then @bsFacts.EquityAttributableToNoncontrollingInterest[fact.Entity][timeIndex] = @chooseFact(@bsFacts.EquityAttributableToNoncontrollingInterest[fact.Entity][timeIndex], fact)
      when 'fac:EquityAttributableToParent' then @bsFacts.EquityAttributableToParent[fact.Entity][timeIndex] = @chooseFact(@bsFacts.EquityAttributableToParent[fact.Entity][timeIndex], fact)

      when 'fac:Revenues' then @isFacts.Revenues[fact.Entity][timeIndex] = @chooseFact(@isFacts.Revenues[fact.Entity][timeIndex], fact)
      when 'fac:CostOfRevenue' then @isFacts.CostOfRevenue[fact.Entity][timeIndex] = @chooseFact(@isFacts.CostOfRevenue[fact.Entity][timeIndex], fact)
      when 'fac:GrossProfit' then @isFacts.GrossProfit[fact.Entity][timeIndex] = @chooseFact(@isFacts.GrossProfit[fact.Entity][timeIndex], fact)
      when 'fac:OperatingExpenses' then @isFacts.OperatingExpenses[fact.Entity][timeIndex] = @chooseFact(@isFacts.OperatingExpenses[fact.Entity][timeIndex], fact)
      when 'fac:CostsAndExpenses' then @isFacts.CostsAndExpenses[fact.Entity][timeIndex] = @chooseFact(@isFacts.CostsAndExpenses[fact.Entity][timeIndex], fact)
      when 'fac:OtherOperatingIncomeExpenses' then @isFacts.OtherOperatingIncomeExpenses[fact.Entity][timeIndex] = @chooseFact(@isFacts.OtherOperatingIncomeExpenses[fact.Entity][timeIndex], fact)
      when 'fac:OperatingIncomeLoss' then @isFacts.OperatingIncomeLoss[fact.Entity][timeIndex] = @chooseFact(@isFacts.OperatingIncomeLoss[fact.Entity][timeIndex], fact)
      when 'fac:NonoperatingIncomeLoss' then @isFacts.NonoperatingIncomeLoss[fact.Entity][timeIndex] = @chooseFact(@isFacts.NonoperatingIncomeLoss[fact.Entity][timeIndex], fact)
      when 'fac:InterestAndDebtExpense' then @isFacts.InterestAndDebtExpense[fact.Entity][timeIndex] = @chooseFact(@isFacts.InterestAndDebtExpense[fact.Entity][timeIndex], fact)
      when 'fac:IncomeLossBeforeEquityMethodInvestments' then @isFacts.IncomeLossBeforeEquityMethodInvestments[fact.Entity][timeIndex] = @chooseFact(@isFacts.IncomeLossBeforeEquityMethodInvestments[fact.Entity][timeIndex], fact)
      when 'fac:IncomeLossFromEquityMethodInvestments' then @isFacts.IncomeLossFromEquityMethodInvestments[fact.Entity][timeIndex] = @chooseFact(@isFacts.IncomeLossFromEquityMethodInvestments[fact.Entity][timeIndex], fact)
      when 'fac:IncomeLossFromContinuingOperationsBeforeTax' then @isFacts.IncomeLossFromContinuingOperationsBeforeTax[fact.Entity][timeIndex] = @chooseFact(@isFacts.IncomeLossFromContinuingOperationsBeforeTax[fact.Entity][timeIndex], fact)
      when 'fac:IncomeTaxExpenseBenefit' then @isFacts.IncomeTaxExpenseBenefit[fact.Entity][timeIndex] = @chooseFact(@isFacts.IncomeTaxExpenseBenefit[fact.Entity][timeIndex], fact)
      when 'fac:IncomeLossFromContinuingOperationsAfterTax' then @isFacts.IncomeLossFromContinuingOperationsAfterTax[fact.Entity][timeIndex] = @chooseFact(@isFacts.IncomeLossFromContinuingOperationsAfterTax[fact.Entity][timeIndex], fact)
      when 'fac:IncomeLossFromDiscontinuedOperationsNetOfTax' then @isFacts.IncomeLossFromDiscontinuedOperationsNetOfTax[fact.Entity][timeIndex] = @chooseFact(@isFacts.IncomeLossFromDiscontinuedOperationsNetOfTax[fact.Entity][timeIndex], fact)
      when 'fac:ExtraordinaryItemsOfIncomeExpenseNetOfTax' then @isFacts.ExtraordinaryItemsOfIncomeExpenseNetOfTax[fact.Entity][timeIndex] = @chooseFact(@isFacts.ExtraordinaryItemsOfIncomeExpenseNetOfTax[fact.Entity][timeIndex], fact)
      when 'fac:NetIncomeLoss' then @isFacts.NetIncomeLoss[fact.Entity][timeIndex] = @chooseFact(@isFacts.NetIncomeLoss[fact.Entity][timeIndex], fact)
      when 'fac:NetIncomeLossAvailableToCommonStockholdersBasic' then @isFacts.NetIncomeLossAvailableToCommonStockholdersBasic[fact.Entity][timeIndex] = @chooseFact(@isFacts.NetIncomeLossAvailableToCommonStockholdersBasic[fact.Entity][timeIndex], fact)
      when 'fac:PreferredStockDividendsAndOtherAdjustments' then @isFacts.PreferredStockDividendsAndOtherAdjustments[fact.Entity][timeIndex] = @chooseFact(@isFacts.PreferredStockDividendsAndOtherAdjustments[fact.Entity][timeIndex], fact)
      when 'fac:NetIncomeLossAttributableToNoncontrollingInterest' then @isFacts.NetIncomeLossAttributableToNoncontrollingInterest[fact.Entity][timeIndex] = @chooseFact(@isFacts.NetIncomeLossAttributableToNoncontrollingInterest[fact.Entity][timeIndex], fact)
      when 'fac:NetIncomeLossAttributableToParent' then @isFacts.NetIncomeLossAttributableToParent[fact.Entity][timeIndex] = @chooseFact(@isFacts.NetIncomeLossAttributableToParent[fact.Entity][timeIndex], fact)
      when 'fac:OtherComprehensiveIncomeLoss' then @isFacts.OtherComprehensiveIncomeLoss[fact.Entity][timeIndex] = @chooseFact(@isFacts.OtherComprehensiveIncomeLoss[fact.Entity][timeIndex], fact)
      when 'fac:ComprehensiveIncomeLoss' then @isFacts.ComprehensiveIncomeLoss[fact.Entity][timeIndex] = @chooseFact(@isFacts.ComprehensiveIncomeLoss[fact.Entity][timeIndex], fact)
      when 'fac:ComprehensiveIncomeLossAttributableToParent' then @isFacts.ComprehensiveIncomeLossAttributableToParent[fact.Entity][timeIndex] = @chooseFact(@isFacts.ComprehensiveIncomeLossAttributableToParent[fact.Entity][timeIndex], fact)
      when 'fac:ComprehensiveIncomeLossAttributableToNoncontrollingInterest' then @isFacts.ComprehensiveIncomeLossAttributableToNoncontrollingInterest[fact.Entity][timeIndex] = @chooseFact(@isFacts.ComprehensiveIncomeLossAttributableToNoncontrollingInterest[fact.Entity][timeIndex], fact)

      when 'fac:NetCashFlow' then @cfFacts.NetCashFlow[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlow[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromOperatingActivities' then @cfFacts.NetCashFlowFromOperatingActivities[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromOperatingActivities[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromInvestingActivities' then @cfFacts.NetCashFlowFromInvestingActivities[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromInvestingActivities[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromFinancingActivities' then @cfFacts.NetCashFlowFromFinancingActivities[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromFinancingActivities[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromOperatingActivitiesContinuing' then @cfFacts.NetCashFlowFromOperatingActivitiesContinuing[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromOperatingActivitiesContinuing[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromInvestingActivitiesContinuing' then @cfFacts.NetCashFlowFromInvestingActivitiesContinuing[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromInvestingActivitiesContinuing[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromFinancingActivitiesContinuing' then @cfFacts.NetCashFlowFromFinancingActivitiesContinuing[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromFinancingActivitiesContinuing[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromOperatingActivitiesDiscontinued' then @cfFacts.NetCashFlowFromOperatingActivitiesDiscontinued[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromOperatingActivitiesDiscontinued[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromInvestingActivitiesDiscontinued' then @cfFacts.NetCashFlowFromInvestingActivitiesDiscontinued[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromInvestingActivitiesDiscontinued[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowFromFinancingActivitiesDiscontinued' then @cfFacts.NetCashFlowFromFinancingActivitiesDiscontinued[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowFromFinancingActivitiesDiscontinued[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowContinuing' then @cfFacts.NetCashFlowContinuing[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowContinuing[fact.Entity][timeIndex], fact)
      when 'fac:NetCashFlowDiscontinued' then @cfFacts.NetCashFlowDiscontinued[fact.Entity][timeIndex] = @chooseFact(@cfFacts.NetCashFlowDiscontinued[fact.Entity][timeIndex], fact)
      when 'fac:ExchangeGainsLosses' then @cfFacts.ExchangeGainsLosses[fact.Entity][timeIndex] = @chooseFact(@cfFacts.ExchangeGainsLosses[fact.Entity][timeIndex], fact)

    if fact.IsDuration
      @durationDates[fact.FiscalPeriod] = {period: fact.FiscalPeriod.split(' ')[0], year: parseInt(fact.FiscalPeriod.split(' ')[1])}
    else
      @instantDates[fact.FiscalPeriod] = {period: fact.FiscalPeriod.split(' ')[0], year: parseInt(fact.FiscalPeriod.split(' ')[1])}
    next()

  formatBSValue: (fact) ->

    if fact.IsNil
      return "nil"

    if fact.GetUnitDescription() is 'USD'
      if fact.Value >= 0
        return "#{fact.Value/1000000.0}"
      else
        return "(#{Math.abs(fact.Value/1000000.0)})"
    else
      return "#{fact.Value/1000000.0}#{fact.GetUnitDescription()}"


  _flush: (next) ->

    outputBsFacts = {}
    sortedInstantDates = (v for k, v of @instantDates)
    sortedInstantDates.sort((a, b) ->

      periodIndices = {Q1: 1, Q2: 2, Q3: 3, YE: 4}

      if a.year > b.year
        return -1
      else if a.year < b.year
        return 1
      else if periodIndices[a.period] > periodIndices[b.period]
        return -1
      else if periodIndices[a.period] < periodIndices[b.period]
        return 1
      else
        return 0)

    outputInstantDates = ("#{date.period} #{date.year}" for date in sortedInstantDates)

    sortedDurationDates = (v for k, v of @durationDates)
    sortedDurationDates.sort((a, b) ->

      periodIndices = {FY: 0, "2H": 1, Q4: 2, "Q1-Q3": 3, "Q2-Q3": 4, Q3: 5, "1H": 6, Q2: 7, Q1: 8}

      if a.year > b.year
        return -1
      else if a.year < b.year
        return 1
      else if periodIndices[a.period] > periodIndices[b.period]
        return 1
      else if periodIndices[a.period] < periodIndices[b.period]
        return -1
      else
        return 0)

    outputDurationDates = ("#{date.period} #{date.year}" for date in sortedDurationDates)

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

    outputIsFacts = {
      Revenues:[],
      CostOfRevenue:[],
      GrossProfit:[],
      OperatingExpenses:[],
      CostsAndExpenses:[],
      OtherOperatingIncomeExpenses:[],
      OperatingIncomeLoss:[],
      NonoperatingIncomeLoss:[],
      InterestAndDebtExpense:[],
      IncomeLossBeforeEquityMethodInvestments:[],
      IncomeLossFromEquityMethodInvestments:[],
      IncomeLossFromContinuingOperationsBeforeTax:[],
      IncomeTaxExpenseBenefit:[],
      IncomeLossFromContinuingOperationsAfterTax:[],
      IncomeLossFromDiscontinuedOperationsNetOfTax:[],
      ExtraordinaryItemsOfIncomeExpenseNetOfTax:[],
      NetIncomeLoss:[],
      NetIncomeLossAvailableToCommonStockholdersBasic:[],
      PreferredStockDividendsAndOtherAdjustments:[],
      NetIncomeLossAttributableToNoncontrollingInterest:[],
      NetIncomeLossAttributableToParent:[],
      OtherComprehensiveIncomeLoss:[],
      ComprehensiveIncomeLoss:[],
      ComprehensiveIncomeLossAttributableToParent:[],
      ComprehensiveIncomeLossAttributableToNoncontrollingInterest:[]
    }

    outputCfFacts = {
      NetCashFlow:[],
      NetCashFlowFromOperatingActivities:[],
      NetCashFlowFromInvestingActivities:[],
      NetCashFlowFromFinancingActivities:[],
      NetCashFlowFromOperatingActivitiesContinuing:[],
      NetCashFlowFromInvestingActivitiesContinuing:[],
      NetCashFlowFromFinancingActivitiesContinuing:[],
      NetCashFlowFromOperatingActivitiesDiscontinued:[],
      NetCashFlowFromInvestingActivitiesDiscontinued:[],
      NetCashFlowFromFinancingActivitiesDiscontinued:[],
      NetCashFlowContinuing:[],
      NetCashFlowDiscontinued:[],
      ExchangeGainsLosses:[],
    }

    for date in sortedInstantDates
      for entity in @entities
        timeIndex = "#{date.period} #{date.year}"
        outputBsFacts.Assets.push(if @bsFacts.Assets[entity][timeIndex]? then @formatBSValue(@bsFacts.Assets[entity][timeIndex]) else null)
        outputBsFacts.CurrentAssets.push(if @bsFacts.CurrentAssets[entity][timeIndex]? then @formatBSValue(@bsFacts.CurrentAssets[entity][timeIndex]) else null)
        outputBsFacts.NoncurrentAssets.push(if @bsFacts.NoncurrentAssets[entity][timeIndex]? then @formatBSValue(@bsFacts.NoncurrentAssets[entity][timeIndex]) else null)
        outputBsFacts.LiabilitiesAndEquity.push(if @bsFacts.LiabilitiesAndEquity[entity][timeIndex]? then @formatBSValue(@bsFacts.LiabilitiesAndEquity[entity][timeIndex]) else null)
        outputBsFacts.Liabilities.push(if @bsFacts.Liabilities[entity][timeIndex]? then @formatBSValue(@bsFacts.Liabilities[entity][timeIndex]) else null)
        outputBsFacts.CurrentLiabilities.push(if @bsFacts.CurrentLiabilities[entity][timeIndex]? then @formatBSValue(@bsFacts.CurrentLiabilities[entity][timeIndex]) else null)
        outputBsFacts.NoncurrentLiabilities.push(if @bsFacts.NoncurrentLiabilities[entity][timeIndex]? then @formatBSValue(@bsFacts.NoncurrentLiabilities[entity][timeIndex]) else null)
        outputBsFacts.CommitmentsAndContingencies.push(if @bsFacts.CommitmentsAndContingencies[entity][timeIndex]? then @formatBSValue(@bsFacts.CommitmentsAndContingencies[entity][timeIndex]) else null)
        outputBsFacts.TemporaryEquity.push(if @bsFacts.TemporaryEquity[entity][timeIndex]? then @formatBSValue(@bsFacts.TemporaryEquity[entity][timeIndex]) else null)
        outputBsFacts.RedeemableNoncontrollingInterest.push(if @bsFacts.RedeemableNoncontrollingInterest[entity][timeIndex]? then @formatBSValue(@bsFacts.RedeemableNoncontrollingInterest[entity][timeIndex]) else null)
        outputBsFacts.Equity.push(if @bsFacts.Equity[entity][timeIndex]? then @formatBSValue(@bsFacts.Equity[entity][timeIndex]) else null)
        outputBsFacts.EquityAttributableToNoncontrollingInterest.push(if @bsFacts.EquityAttributableToNoncontrollingInterest[entity][timeIndex]? then @formatBSValue(@bsFacts.EquityAttributableToNoncontrollingInterest[entity][timeIndex]) else null)
        outputBsFacts.EquityAttributableToParent.push(if @bsFacts.EquityAttributableToParent[entity][timeIndex]? then @formatBSValue(@bsFacts.EquityAttributableToParent[entity][timeIndex]) else null)

    for date in sortedDurationDates
      for entity in @entities
        timeIndex = "#{date.period} #{date.year}"
        outputIsFacts.Revenues.push(if @isFacts.Revenues[entity][timeIndex]? then @formatBSValue(@isFacts.Revenues[entity][timeIndex]) else null)
        outputIsFacts.CostOfRevenue.push(if @isFacts.CostOfRevenue[entity][timeIndex]? then @formatBSValue(@isFacts.CostOfRevenue[entity][timeIndex]) else null)
        outputIsFacts.GrossProfit.push(if @isFacts.GrossProfit[entity][timeIndex]? then @formatBSValue(@isFacts.GrossProfit[entity][timeIndex]) else null)
        outputIsFacts.OperatingExpenses.push(if @isFacts.OperatingExpenses[entity][timeIndex]? then @formatBSValue(@isFacts.OperatingExpenses[entity][timeIndex]) else null)
        outputIsFacts.CostsAndExpenses.push(if @isFacts.CostsAndExpenses[entity][timeIndex]? then @formatBSValue(@isFacts.CostsAndExpenses[entity][timeIndex]) else null)
        outputIsFacts.OtherOperatingIncomeExpenses.push(if @isFacts.OtherOperatingIncomeExpenses[entity][timeIndex]? then @formatBSValue(@isFacts.OtherOperatingIncomeExpenses[entity][timeIndex]) else null)
        outputIsFacts.OperatingIncomeLoss.push(if @isFacts.OperatingIncomeLoss[entity][timeIndex]? then @formatBSValue(@isFacts.OperatingIncomeLoss[entity][timeIndex]) else null)
        outputIsFacts.NonoperatingIncomeLoss.push(if @isFacts.NonoperatingIncomeLoss[entity][timeIndex]? then @formatBSValue(@isFacts.NonoperatingIncomeLoss[entity][timeIndex]) else null)
        outputIsFacts.InterestAndDebtExpense.push(if @isFacts.InterestAndDebtExpense[entity][timeIndex]? then @formatBSValue(@isFacts.InterestAndDebtExpense[entity][timeIndex]) else null)
        outputIsFacts.IncomeLossBeforeEquityMethodInvestments.push(if @isFacts.IncomeLossBeforeEquityMethodInvestments[entity][timeIndex]? then @formatBSValue(@isFacts.IncomeLossBeforeEquityMethodInvestments[entity][timeIndex]) else null)
        outputIsFacts.IncomeLossFromEquityMethodInvestments.push(if @isFacts.IncomeLossFromEquityMethodInvestments[entity][timeIndex]? then @formatBSValue(@isFacts.IncomeLossFromEquityMethodInvestments[entity][timeIndex]) else null)
        outputIsFacts.IncomeLossFromContinuingOperationsBeforeTax.push(if @isFacts.IncomeLossFromContinuingOperationsBeforeTax[entity][timeIndex]? then @formatBSValue(@isFacts.IncomeLossFromContinuingOperationsBeforeTax[entity][timeIndex]) else null)
        outputIsFacts.IncomeTaxExpenseBenefit.push(if @isFacts.IncomeTaxExpenseBenefit[entity][timeIndex]? then @formatBSValue(@isFacts.IncomeTaxExpenseBenefit[entity][timeIndex]) else null)
        outputIsFacts.IncomeLossFromContinuingOperationsAfterTax.push(if @isFacts.IncomeLossFromContinuingOperationsAfterTax[entity][timeIndex]? then @formatBSValue(@isFacts.IncomeLossFromContinuingOperationsAfterTax[entity][timeIndex]) else null)
        outputIsFacts.IncomeLossFromDiscontinuedOperationsNetOfTax.push(if @isFacts.IncomeLossFromDiscontinuedOperationsNetOfTax[entity][timeIndex]? then @formatBSValue(@isFacts.IncomeLossFromDiscontinuedOperationsNetOfTax[entity][timeIndex]) else null)
        outputIsFacts.ExtraordinaryItemsOfIncomeExpenseNetOfTax.push(if @isFacts.ExtraordinaryItemsOfIncomeExpenseNetOfTax[entity][timeIndex]? then @formatBSValue(@isFacts.ExtraordinaryItemsOfIncomeExpenseNetOfTax[entity][timeIndex]) else null)
        outputIsFacts.NetIncomeLoss.push(if @isFacts.NetIncomeLoss[entity][timeIndex]? then @formatBSValue(@isFacts.NetIncomeLoss[entity][timeIndex]) else null)
        outputIsFacts.NetIncomeLossAvailableToCommonStockholdersBasic.push(if @isFacts.NetIncomeLossAvailableToCommonStockholdersBasic[entity][timeIndex]? then @formatBSValue(@isFacts.NetIncomeLossAvailableToCommonStockholdersBasic[entity][timeIndex]) else null)
        outputIsFacts.PreferredStockDividendsAndOtherAdjustments.push(if @isFacts.PreferredStockDividendsAndOtherAdjustments[entity][timeIndex]? then @formatBSValue(@isFacts.PreferredStockDividendsAndOtherAdjustments[entity][timeIndex]) else null)
        outputIsFacts.NetIncomeLossAttributableToNoncontrollingInterest.push(if @isFacts.NetIncomeLossAttributableToNoncontrollingInterest[entity][timeIndex]? then @formatBSValue(@isFacts.NetIncomeLossAttributableToNoncontrollingInterest[entity][timeIndex]) else null)
        outputIsFacts.NetIncomeLossAttributableToParent.push(if @isFacts.NetIncomeLossAttributableToParent[entity][timeIndex]? then @formatBSValue(@isFacts.NetIncomeLossAttributableToParent[entity][timeIndex]) else null)
        outputIsFacts.OtherComprehensiveIncomeLoss.push(if @isFacts.OtherComprehensiveIncomeLoss[entity][timeIndex]? then @formatBSValue(@isFacts.OtherComprehensiveIncomeLoss[entity][timeIndex]) else null)
        outputIsFacts.ComprehensiveIncomeLoss.push(if @isFacts.ComprehensiveIncomeLoss[entity][timeIndex]? then @formatBSValue(@isFacts.ComprehensiveIncomeLoss[entity][timeIndex]) else null)
        outputIsFacts.ComprehensiveIncomeLossAttributableToParent.push(if @isFacts.ComprehensiveIncomeLossAttributableToParent[entity][timeIndex]? then @formatBSValue(@isFacts.ComprehensiveIncomeLossAttributableToParent[entity][timeIndex]) else null)
        outputIsFacts.ComprehensiveIncomeLossAttributableToNoncontrollingInterest.push(if @isFacts.ComprehensiveIncomeLossAttributableToNoncontrollingInterest[entity][timeIndex]? then @formatBSValue(@isFacts.ComprehensiveIncomeLossAttributableToNoncontrollingInterest[entity][timeIndex]) else null)

        outputCfFacts.NetCashFlow.push(if @cfFacts.NetCashFlow[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlow[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromOperatingActivities.push(if @cfFacts.NetCashFlowFromOperatingActivities[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromOperatingActivities[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromInvestingActivities.push(if @cfFacts.NetCashFlowFromInvestingActivities[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromInvestingActivities[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromFinancingActivities.push(if @cfFacts.NetCashFlowFromFinancingActivities[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromFinancingActivities[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromOperatingActivitiesContinuing.push(if @cfFacts.NetCashFlowFromOperatingActivitiesContinuing[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromOperatingActivitiesContinuing[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromInvestingActivitiesContinuing.push(if @cfFacts.NetCashFlowFromInvestingActivitiesContinuing[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromInvestingActivitiesContinuing[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromFinancingActivitiesContinuing.push(if @cfFacts.NetCashFlowFromFinancingActivitiesContinuing[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromFinancingActivitiesContinuing[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromOperatingActivitiesDiscontinued.push(if @cfFacts.NetCashFlowFromOperatingActivitiesDiscontinued[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromOperatingActivitiesDiscontinued[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromInvestingActivitiesDiscontinued.push(if @cfFacts.NetCashFlowFromInvestingActivitiesDiscontinued[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromInvestingActivitiesDiscontinued[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowFromFinancingActivitiesDiscontinued.push(if @cfFacts.NetCashFlowFromFinancingActivitiesDiscontinued[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowFromFinancingActivitiesDiscontinued[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowContinuing.push(if @cfFacts.NetCashFlowContinuing[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowContinuing[entity][timeIndex]) else null)
        outputCfFacts.NetCashFlowDiscontinued.push(if @cfFacts.NetCashFlowDiscontinued[entity][timeIndex]? then @formatBSValue(@cfFacts.NetCashFlowDiscontinued[entity][timeIndex]) else null)
        outputCfFacts.ExchangeGainsLosses.push(if @cfFacts.ExchangeGainsLosses[entity][timeIndex]? then @formatBSValue(@cfFacts.ExchangeGainsLosses[entity][timeIndex]) else null)

    @push({instantDates: outputInstantDates, durationDates: outputDurationDates, bsFacts: outputBsFacts, isFacts: outputIsFacts, cfFacts: outputCfFacts})
    next()
