var w = 400,
    h = 400,
    r = Math.min(w, h) / 2,
    data = d3.range(10).map(Math.random),
    color = d3.scale.category20(),
    donut = d3.layout.pie().sort(d3.descending),
    arc = d3.svg.arc().innerRadius(r * .3).outerRadius(r);

var vis = d3.select("#chart")
  .append("svg:svg")
    .data([data])
    .attr("width", w)
    .attr("height", h);

var arcs = vis.selectAll("g.arc")
    .data(donut)
  .enter().append("svg:g")
    .attr("class", "arc")
    .attr("transform", "translate(" + r + "," + r + ")");

arcs.append("svg:path")
    .attr("fill", function(d, i) { return color(i); })
    .attr("d", arc);

arcs.append("svg:text")
    .attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
    .attr("dy", ".35em")
    .attr("text-anchor", "middle")
    .attr("display", function(d) { return d.value > .15 ? null : "none"; })
    .text(function(d, i) { return d.value.toFixed(2); });
