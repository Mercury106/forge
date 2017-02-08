App.SiteGraphView = Ember.View.extend

  templateName: 'site/_graph'

  content: null
  loaded: false
  
  didInsertElement: ->
    @renderGraph()
    $(window).on 'resize', => @renderGraph()

  noData: (->
    @get('content.isLoaded') && @get('content.length') == 0
  ).property('content', 'loaded', 'content.@each', 'content.isLoaded')

  renderGraph: (->
    @set('loaded', true)
    data = @get('content')
    margin = top: 20, right: 0, bottom: 30, left: -1
    view = @
    
    if data?.get('length') > 0
      
      @$('#graph').empty()
      width = @$().width() - margin.left - margin.right
      height = 300 - margin.top - margin.bottom
      parseDate = d3.time.format("%Y-%m-%d").parse
      
      x = d3.time.scale().range([0, width])
      y = d3.scale.linear().range([height, 0])
      
      xAxis = d3.svg.axis().scale(x).orient("bottom")
      yAxis = d3.svg.axis().scale(y).orient("left")
      
      bytes = 0
      area = d3.svg.area()
        .interpolate("bundle")   
        .x((d) -> x d.get('date'))
        .y0(height).y1((d) -> y(d.get('bytes') / 1000 / 1000))
      
      window.area = area
      
      svg = d3.select("#graph").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      
      x.domain d3.extent(data.toArray(), (d) -> d.get('date'))
      y.domain [0, d3.max(data.toArray(), (d) -> d.get('bytes') / 1000 / 1000)]
      
      svg.append("path")
        .datum(data.toArray())
        .attr("class", "area")
        .attr("d", area)
        # .on('mousedown', (data) ->
          
        #   date = x.invert d3.mouse(this)[0]
        #   view.set('first_date', new Date(date.getTime()))
          
        # ).on('mouseup', (data) ->
          
        #   view.set('first_date', null)  
          
        # ).on('mousemove', (data) ->
          
        #   date = x.invert d3.mouse(this)[0]
          
        #   if view.get('first_date')
        #     first_date = view.get('first_date')
        #   else
        #     first_date = new Date date.getTime()
        #     first_date.setHours first_date.getHours() - 0.5
            
        #   last_date = new Date date.getTime()
          
        #   last_date.setHours last_date.getHours() + 0.5
          
        #   view.set('start_date', first_date)
        #   view.set('end_date', last_date)
          
        #   dates = [first_date, last_date].sort (a, b) ->
        #     if (a>b) then 1
        #     else if a < b then -1
        #     else 0
            
        #   first_date = dates[0]
        #   last_date = dates[1]
          
        #   usages = App.SiteUsage.all().filter (usage) -> 
        #     usage.get('date') <= last_date && usage.get('date') >= first_date
          
        #   window.usages = usages
        #   window.a = first_date
        #   window.b = last_date
          
        #   sum = 0
          
        #   for bytes in usages.mapProperty('bytes')
        #     sum += parseInt(bytes)
          
        #   view.set('bytes', sum)
        # )

      svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call xAxis
      # svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text "MB"
      
  ).observes('content.isLoaded')