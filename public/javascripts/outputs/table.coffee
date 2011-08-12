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
    vis = d3.select($("<div>").get(0))
      .append("table")
      .append("tbody")

    # TODO(sissel): add a way to inject a header.

    header = (key for key,val of result[0])
    # TODO(sissel): will need some custom templating tool to pick out the columns, etc.
    vis.selectAll("tr")
      .data(result)
      .enter()
        .append("tr")
        .html((d) => @row(d))

    # TODO(sissel): Would be nice to ship a table header with d3 instead of jquery.
    #vis.selectAll("tr")
      #.append("tr")
      #.data((key for key of result[0]))
      #.enter()
        #.append("th")
        #.text((d) => d)

    # vis[0] is the tbody, we want the table
    el = $(vis[0]).parent()
    # TODO(sissel): Use d3 string formatting.
    columns = ("<th>" + key + "</th>" for key of result[0])
    header = $("<tr>" + columns + "</tr>")
    header.addClass("header")
    el.prepend(header)

    $(el).attr("cellspacing", 0)
    $(el).attr("cellpadding", 0)

    # 'vis' appears to be a one-element array containing the div. Turn it into
    # a jquery context before returning.
    return el
  
  row: (data) ->
    # TODO(sissel): Use jquery templating?
    if data._source?
      return "<td style='font-family:monospace; white-space: pre'>" + data._source["@timestamp"] + "</td>" +
             "<td>" + data._source["@message"] + "</td>"
    else
      str = ""
      for key, val of data
        str += "<td>" + val + "</td>"
      return str
  # end display
# end class PieChart
  
exports = window.TableChart = TableChart
