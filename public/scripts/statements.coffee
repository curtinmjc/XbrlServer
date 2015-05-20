class StatementsController
  constructor: (@$scope, @$http) ->
    @initialize()
    @entities = []

  addEntity: ->
    if @selectedEntity? and @selectedEntity.originalObject? and !@entities.some((entity) => entity.id is @selectedEntity.originalObject.id)
      @entities.push(@selectedEntity.originalObject)
      @initialize()
      @showStatements()

  initialize: ->
    @selectedEntity = null
    @instantDates = []
    @durationDates = []
    @instantEntities = []
    @durationEntities = []
    @bsFacts = {}
    @isFacts = {}
    @cfFacts = {}
    @loading = false
    @loaded = false

  startOver: ->
    @initialize()
    @entities = []

  showStatements: ->
    identifiers = (entity.id for entity in @entities)
    @loading = true
    @$http.post('statementData', {entities: identifiers}).success((data, status, headers, config) =>
      @instantDates = data.instantDates
      for date in data.instantDates
        for entity in @entities
          @instantEntities.push(entity.value)

      @bsFacts = data.bsFacts

      @durationDates = data.durationDates
      for date in data.durationDates
        for entity in @entities
          @durationEntities.push(entity.value)

      @isFacts = data.isFacts
      @cfFacts = data.cfFacts
      @loading = false
      @loaded = true
    )



StatementsController.$inject = ["$scope", "$http"]

angular.module("statementsApp", ["angucomplete"]).controller("StatementsController", StatementsController)

$ ->
  $('#bsTableRight').height($('#bsTable').height()+10)
  $('#isTableRight').height($('#isTable').height()+10)
  $('#cisTableRight').height($('#cisTable').height()+10)
  $('#cfTableRight').height($('#cfTable').height()+10)
