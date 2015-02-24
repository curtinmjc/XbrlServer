chart = null;
cloneToolTip = null;

a2a_config = a2a_config || {};
a2a_config.num_services = 4;

$ ->

  retrieveInProgress = false
  shareControlsShowing = false

  Date.prototype.addDays = (num) ->
    value = this.valueOf()
    value += 86400000 * num
    return new Date(value)

  $.ajax(url: "/size", success: (numDataPoints) ->
    $('#numDataPoints').text(numDataPoints))

  cloneToolTip = null;
  cloneToolTip2 = null;

  removePinnedToolTip = () ->
    if (cloneToolTip)then chart.container.firstChild.removeChild(cloneToolTip)
    if (cloneToolTip2) then cloneToolTip2.remove()
    cloneToolTip = null;
    cloneToolTip2 = null;

  remove = (arr, itemToRemove) ->
    for num in [0..arr.length]
      arr.splice(num, 1) if (arr[num] is itemToRemove)


  chart = new Highcharts.Chart({
    chart: { renderTo: 'chart-container' }
    xAxis: {type: 'datetime'}
    title: {text: 'waiting...'}
    exporting: { chartOptions: { chart: { backgroundColor: "#000000" } } }
    tooltip: { useHTML: true, formatter: () ->
        renderingDataIndex = "#{@x}--#{@y}"
        "#{new Date(@x).toDateString()}: <b>#{@y} #{@series.renderingData[renderingDataIndex].unit}</b><br><a style=\"float: left;\" target=\"_blank\" href=\"#{@series.renderingData[renderingDataIndex].rendering}\">View Rendering</a><a style=\"float: right;\" target=\"_blank\" href=\"#{@series.renderingData[renderingDataIndex].xml}\">View XML</a>"
      }
    plotOptions:{
      line: { marker: {enabled: true} }
      series: {
        cursor: 'pointer', point: {
          events: {
            click: () ->
              removePinnedToolTip()
              cloneToolTip = @series.chart.tooltip.label.element.cloneNode(true)
              chart.container.firstChild.appendChild(cloneToolTip)

              cloneToolTip2 = $('.highcharts-tooltip').clone()
              $(chart.container).append(cloneToolTip2)
          }
        }
        events: {
          legendItemClick: () ->
            displayedSeries[@shareKey] = if @visible then "false" else "true"
            hideShareControls()
            return true
        }
      }
    }
  })

  slider = $('.bxslider').bxSlider(
    {
      infiniteLoop: false,
      controls: false
      pager: false
      touchEnabled: false
    }
  )

  hideShareControls = () ->
    if shareControlsShowing
      $("#shareControls").html('<a id="share" href="#" class="btn btn-sm btn-primary" style="width: 100px"><img src="/images/share16.png" style="margin-right: 10px;">Share</a>').on("click", -> shareClick())
      shareControlsShowing = false

  populateChartInternal = (docs) ->
    if (not docs? or docs.length is 0)
      alert("There doesn't seem to be any data.")
      retrieveInProgress = false
      return

    slider.goToSlide(1);

    el = $('#chart-container')
    el.css('width','100%')

    chartTitle = ''
    for displayedSet in displayedSets
      chartTitle += "[#{displayedSet.companyName}]:#{displayedSet.conceptName} vs. "
    chartTitle = chartTitle.substring(0, chartTitle.length - 5)

    chart.setTitle({text: chartTitle})

    for k,v of docs
      displayedSeries[v.shareKey] = "false" if not displayedSeries[v.shareKey]?

      addedSeries = chart.addSeries({data: v.data, name: k, visible: displayedSeries[v.shareKey] is "true"})
      addedSeries.renderingData = v.renderingData
      addedSeries.shareKey = v.shareKey
    chart.setSize(el.width(),el.height(),true)

    $("#externalSliderControls").toggleClass("hiddenElement")


  populateChart = () ->
    return if retrieveInProgress

    retrieveInProgress = true

    $('#addSeries').toggleClass('button-ajax-loading')

    identifier = $('#identifier').val()
    companyName = $('#company').val()
    conceptName = $('#concept').val()

    $.ajax(url: "/facts?identifier=#{identifier}&conceptName=#{conceptName}", dataType: 'json'
      ,
      success: (docs) ->
        displayedSets.push({identifier: identifier, companyName: companyName, conceptName: conceptName})

        for k,v of docs
          displayedSeries[v.shareKey] = "true"

        populateChartInternal(docs)
      ,
      complete: () ->
        retrieveInProgress = false
        $('#addSeries').toggleClass('button-ajax-loading')
    )

  validateConcept = () ->
    if not $('#concept').val()? or $('#concept').val() is ''
      $('#concept').addClass('errorBox')
      return false
    else
      $('#concept').removeClass('errorBox')
      return true

  validateCompany = () ->
    if not $('#identifier').val()? or $('#identifier').val() is ''
      $('#company').addClass('errorBox')
      return false
    else
      $('#company').removeClass('errorBox')
      return true


  validateAll = () ->
    return validateCompany() and validateConcept()

  $('.navbar li a').click((event) ->
      event.preventDefault()
      $($(this).attr('href'))[0].scrollIntoView()
      scrollBy(0, -50))

  $('#concept').autocomplete(
    {
      delay: 300,
      minLength: 3,
      source: (req, res) ->
        $.ajax(
            #url: '/elements/' + $('#identifier').val() + '?term=' + req.term,
            url: '/elements?identifier=' + $('#identifier').val() + '&term=' + req.term,
            dataType: 'json',
            success: (data) ->
              res(data)
        )
      ,
      change: (e, ui) ->
        if not ui.item
          $('#concept').val('')
      ,
      position: { my : "center top", at: "center bottom", of: '#concept' }
    })

  $('#company').autocomplete(
    {
      delay: 300,
      source: (req, res) ->
        $.ajax(
          url: '/companies?term=' + req.term,
          dataType: 'json',
          success: (data) ->
            res(data)
        )
      ,
      select: (event, ui) ->
        event.preventDefault()
        $("#company").val(ui.item.label)
        $("#identifier").val(ui.item.id)
      ,
      focus: (event, ui) ->
        event.preventDefault()
        $("#company").val(ui.item.label)
        $("#identifier").val(ui.item.id)
      ,
      change: (e, ui) ->
        if not ui.item
          $('#identifier').val('')
          $('#company').val('')
      ,
      position: { my : "center top", at: "center bottom", of: '#company' }
    })

  shareClick = () ->
    $.ajax(
      type: "POST",
      url: "/save",
      data: {sets: displayedSets, series: displayedSeries},
      success: ((id) ->
        $("#shareControls").html('<iframe id="shareControls" style="border: none; margin: 0px; padding: 0px; overflow: hidden;" height="26px" width="600px" scrolling="no" seamless="seamless" src="/share/' + id + '"></iframe>')
        shareControlsShowing = true
      )
      dataType: 'text'
    )

  $("#share").on("click", -> shareClick())

  $("#addAnother").on("click", ->
    window.facts = null
    window.history.pushState({path:'/'},'','/');
    $("#externalSliderControls").toggleClass("hiddenElement")
    removePinnedToolTip()
    hideShareControls()
    $("#company").focus()
    slider.goToSlide(0);
  )

  $("#startOver").on("click", ->
    window.displayedSets = []
    window.displayedSeries = {}
    window.facts = null
    window.history.pushState({path:'/'},'','/');
    removePinnedToolTip()
    chart.setTitle({text: 'waiting...'})
    while chart.series.length > 0
      chart.series[0].remove(true)
    hideShareControls()

    $("#externalSliderControls").toggleClass("hiddenElement")
    $("#concept").val('')
    $("#company").val('')
    $("#identifier").val('')
    $("#company").focus()
    slider.goToSlide(0);
  )

  $("#addSeries").on("click", ->
    populateChart() if validateAll()
  )

  $("#company").focusout( () ->
    validateCompany()
  )

  $("#concept").focusout( () ->
    validateConcept()
  )

  if facts?
    populateChartInternal(facts)
  else
    $('#company').focus()



