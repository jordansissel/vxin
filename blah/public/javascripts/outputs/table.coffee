class TableChart # extends Output
  @name = [ "table" ]

  constructor: (settings) ->
    # TODO(sissel): Include a way to specify the columns
  # end constructor

  receive: (result) ->
    # Generate an HTML table.
    vis = d3.select($("#visual").get(0))
      .append("table")

    vis.selectAll("tr")
      .data(result)
      .enter()
        .append("tr")
        .html((d) -> 
          "<td style='font-family:monospace; white-space: pre'>" + d._source["@timestamp"] + "</td>" +
          "<td>" + d._source["@message"] + "</td>"
        )
  # end display
# end class PieChart
  
exports = window.TableChart = TableChart
