#= require 'admin/maps/map'
class ForgeAdmin.UserMap extends ForgeAdmin.Map

  setupElement: () ->
    margin = {top: 20, right: 20, bottom: 30, left: 50}
    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom;
    @height = height

    @x = d3.time.scale()
        .range([0, width]);

    @y = d3.scale.linear()
        .range([height, 0]);

    @xAxis = d3.svg.axis()
        .scale(@x)
        .orient("bottom");

    @yAxis = d3.svg.axis()
        .scale(@y)
        .orient("left");

    @svg = d3.select(@element).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  loadData: ->
    @data ||= {}
    d3.json "/admin/users/paid.json", (data, error) =>
      @data['paid'] = data
      window.data = data
      @renderUsers()
    d3.json "/admin/users/all.json", (data, error) =>
      @data['all'] = data
      @renderUsers()

  renderUsers: (data) ->
    @svg.select('path').remove()

    sum = 0
    @lines ||= []
    allData = []

    $.each @data, (name, data) =>
      $.each data, (i, d) =>
        allData.push d

    $.each @data, (name, data) =>
      $.each data, (i, d) =>
        d.date = @parseDate(d.created_at)
        d.id = sum
        sum++

      line = d3.svg.line()
      line.x (d) => @x(d.date)
      line.y (d) => @y(d.id)

      @x.domain d3.extent(allData, (d) -> return d.date)
      @y.domain d3.extent(allData, (d) -> return d.id)

      @svg.append("path")
          .datum(data)
          .attr("class", "line users-#{name}")
          .attr("d", line)

    @renderAxes()

  renderAxes: ->
    if @xAxisLine || @yAxisLine
      @yAxisLine.remove()
      @xAxisLine.remove()

    @xAxisLine = @svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + @height + ")")
        .call(@xAxis)

    @yAxisLine = @svg.append("g")
        .attr("class", "y axis")
        .call(@yAxis)

    @yAxisLine.append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("User ID")

# window.UserMap = UserMap