class LogglyInput
  constructor: () ->
    console.log("OK")
    @facets = {}
    @query = ""
  # end constructor

  search: (query) ->
    @query = query
    return this
  # end search

  facet_ip: (query) ->
    @path = "/api/facets/ip"
    @query = query
    @params = {
      #"q": query,
      "format": "json"
    }
  # end facet_ip

  run: (callback) ->
    url = "https://jls.loggly.com" + @path + "?callback=?"
    #jQuery.getJSON("https://jls.loggly.com" + @path + "?callback=?",
    #@params, (data, status, xhr) => callback(data, status, xhr))
    jQuery.ajax({
      url: url,
      dataType: "jsonp",
      cache: true,
      data: @params,
      success: (data, status, xhr) => callback(data, status, xhr),
    });
  # end run

  # TODO(sissel): This kind of display feature will be an 'output' in the
  # long-term.
  display: (results) ->
    console.log(results)

    h = w = 200
    r = w / 2
    counts = {}
    data = []
    scaledata = []
    terms = []
    for term, count of results.data
      # Scale the data with log() so tiny values show up.
      data.push(count)
      #scaledata.push(Math.log(count))
      terms.push(term)

    scaledata = data

    color = d3.scale.category20()
    donut = d3.layout.pie().sort(d3.descending)
    #arc = d3.svg.arc().innerRadius(r * .3).outerRadius(r)
    arc = d3.svg.arc().innerRadius(0).outerRadius(r)

    piechart = $("#templates .piechart").clone()
    chart = $(".chart", piechart)

    vis = d3.select(chart.get(0))
      .append("svg:svg")
        .data([scaledata])
        .attr("width", w)
        .attr("height", h)

    arcs = vis.selectAll("g.arc")
        .data(donut)
      .enter().append("svg:g")
        .attr("class", "arc")
        .attr("transform", "translate(" + r + "," + r + ")")

    slices = arcs.append("svg:path")
        .attr("fill",(d, i) => color(i))
        .attr("d", arc)

    for slice, index in slices[0]
      $(slice).click({ "index": index }, (e) => 
        console.log("click on " + e.data.index + ":" + terms[e.data.index])
      )

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

    template_html = $("tr.template", piechart).html()
    jQuery.template("blah", template_html)
    table = $(".table table", piechart)
    for count, index in data
      term = terms[index]
      row = jQuery("<tr>")
      jQuery.tmpl("blah", {
        "name": term,
        "value": count
      }).appendTo(row)
      row.appendTo(table)

    $("caption", piechart).text("Results for query '" + @query + "', facet by ip")

    $("#visual").empty().append(piechart)
  # end display
# end class ElasticSearchInput

e = new LogglyInput()
e.facet_ip("*")
e.run((result) => e.display(result))
