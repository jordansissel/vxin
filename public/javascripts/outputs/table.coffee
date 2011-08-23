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
    settings ?= {}
    @columns = settings.columns
    @header = settings.header ? true
    @column_config = settings.column_config ? {}
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
          .classed("widget-table-row", true)
          .html((d) => 
            # TODO(sissel): Special handling for jQuery or HTMLElement objects?
            row = @row(d)
            return row
          )

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
    
    if @header 
      # TODO(sissel): Handle column renaes?
      if @columns?
        text_columns = []
        for column in @columns
          console.log("column", column)
          if typeof(column) == "object"
            for name, value of column
              text_columns.push(name)
          else
            text_columns.push(column)
        # end for each @columns
        columns = ("<th>" + @text(key) + "</th>" for key in text_columns)
      else
        columns = ("<th>" + @text(key) + "</th>" for key in result[0])
      header = $("<tr>" + columns + "</tr>").addClass("widget-table-header")
      #header.addClass("header")
      el.prepend(header)
    # if @header?

    $(el).attr("cellspacing", 0)
    $(el).attr("cellpadding", 0)

    # 'vis' appears to be a one-element array containing the div. Turn it into
    # a jquery context before returning.
    $(el).addClass("zebra-striped")
    return el

  text: (column) ->
    return @column_config[column] ? column

  class: (column) ->
    config = @column_config[column]
    return config
  
  row: (data) ->
    # TODO(sissel): yield HTML elements
    # TODO(sissel): Use jquery templating?
    if @columns?
      tr = $("<tr>")
      for column in @columns
        # column is a single element hash of name:value
        # TODO(sissel): handle this in a function
        [name, value] = ["", ""]
        if typeof(column) == "object"
          for name, value_script of column
            true
          _ = data
          console.log("valuescript", value, value_script)
          value = eval(value_script)
        else
          value = data[column]

        td = $("<td>").addClass(@class(column)).text(value)
        tr.append(td)
      return tr.html()
    else
      #str = ""
      tr = $("<tr>")
      for key, val of data
        td = $("<td>").addClass(@class(key)).text(val)
        tr.append(td)
      return tr.html()
  # end display
# end class TableChart
  
exports = window.TableChart = TableChart
