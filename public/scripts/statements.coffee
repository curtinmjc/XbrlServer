class StatementsController
  constructor: (@$scope, @$http) ->
    @entities = [{name: 'IBM', identifier: "http://www.sec.gov/CIK/0000051143"}, {name: 'MSFT', identifier: "http://www.sec.gov/CIK/0000789019"}]
    @instantDates = []
    @durationDates = []
    @instantEntities = []
    @durationEntities = []
    @bsFacts = {}
    @loading = false
    @loaded = false
    @showStatements()

  showStatements: ->
    identifiers = (entity.identifier for entity in @entities)
    @loading = true
    @$http.post('statementData', {entities: identifiers}).success((data, status, headers, config) =>
      @instantDates = data.instantDates
      for date in data.instantDates
        for entity in @entities
          @instantEntities.push(entity.name)

      @bsFacts = data.bsFacts

      @durationDates = data.durationDates
      for date in data.durationDates
        for entity in @entities
          @durationEntities.push(entity.name)

      @isFacts = data.isFacts
      @cfFacts = data.cfFacts
      @loading = false
      @loaded = true
    )



StatementsController.$inject = ["$scope", "$http"]

angular.module("statementsApp", []).controller("StatementsController", StatementsController)

$ ->
  $('#bsTableRight').height($('#bsTable').height())
  $('#isTableRight').height($('#isTable').height())
  $('#cisTableRight').height($('#cisTable').height())
  $('#cfTableRight').height($('#cfTable').height())

