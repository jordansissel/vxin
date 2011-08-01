class TableChart # extends Output
  @name = [ "table" ]

  constructor: (settings) ->
    # TODO(sissel): support column specs.
    #
    # - Set the columns to display, in order left to right.
    # settings.columns = [
    #   { "name": "value" },
    #   ...
    # ]
    #
    # - Set the class on the <table> element
    # settings.className = "classname"
    #
    # TODO(sissel): What other settings might we want?
    # name is the field header
    # value is the field to access; the '_' variable is the object.
    #
    # Example:
    #   settings.columns = [
    #     { "timestamp": "_._source[\"@timestamp\"]" }
    #     { "message": "_._source[\"@message\"]" }
    #   ]
  # end constructor

  receive: (result) ->
    # Generate an HTML table.
    vis = d3.select($("#visual").get(0))
      .append("table")

    # TODO(sissel): will need some custom templating tool to pick out the columns, etc.
    vis.selectAll("tr")
      .data(result)
      .enter()
        .append("tr")
        .html((d) => @row(d))
  
  row: (data) ->
    return "<td style='font-family:monospace; white-space: pre'>" + data._source["@timestamp"] + "</td>" +
           "<td>" + data._source["@message"] + "</td>"
  # end display
# end class PieChart
  
exports = window.TableChart = TableChart
