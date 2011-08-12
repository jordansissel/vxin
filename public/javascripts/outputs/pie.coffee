class PieChart # extends Output
  @name = [ "pie" ]

  constructor: (settings) ->
    settings ?= {}
    @height = @width = settings.size ? 200
    @radius = @width / 2
  # end constructor

  receive: (results) ->
    counts = {}
    data = []
    scaledata = []
    terms = []
    result_array = []

    #console.log("pie data", results)
    for point in results
      #console.log("point", point.key, point.count)
      result_array.push([point.key, point.count])

    #result_array.sort((a, b) => a[1] - b[1])

    for kv in result_array
      terms.push(kv[0])
      data.push(kv[1])
      # TODO(sissel): ??? Scale the data with log() so tiny values show up.
      #console.log("point", point.key, point.count)

    color = d3.scale.category20()
    pie = d3.layout.pie().sort(d3.descending)
    arc = d3.svg.arc().innerRadius(0).outerRadius(@radius)
    vis = d3.select($("<div>").get(0))

    svg = vis.append("svg:svg")
        .data([data])
        .attr("width", @width)
        .attr("height", @height)

    arcs = svg.selectAll("g.arc")
        .data(pie)
      .enter().append("svg:g")
        .attr("class", "arc")
        .attr("transform", "translate(" + @radius + "," + @radius + ")")

    slices = arcs.append("svg:path")
        .attr("fill",(d, i) => color(i))
        .attr("d", arc)

    #for slice, index in slices[0]
      #$(slice).click({ "index": index }, (e) => 
        #console.log("click on " + e.data.index + ":" + terms[e.data.index])
      #)

    arcs.append("svg:text")
        .attr("transform", (d) => 
          #rotation = ((d.startAngle + d.endAngle) / 2) / (Math.PI * 2) * 360
          #rotation += 180 if rotation < 0
          #rotation -= 180 if rotation > 180
          #console.log(rotation)
          #"translate(" + arc.centroid(d) + ")rotate(" + (rotation - 90)+ ")"
          "translate(" + arc.centroid(d) + ")"
        )
        .attr("dy", ".35em")
        .attr("text-anchor", "middle")
        .attr("display", (d) => 
          d.value > .15 ? null : "none")
        .text((d, i) => terms[i] )

    return $(vis[0])
  # end receive
# end class PieChart
  
exports = window.PieChart = PieChart
