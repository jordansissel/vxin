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
  
  generate_columns: (result) ->
    # TODO(sissel): too much going on here, split it up.
      # results[0] here is safe because we check 'results' length above.
      found_columns = @detect_columns(result[0])
      #columns = ("<th>" + @text(key) + "</th>" for key in found_columns)
      columns = ("<th>" + @text(key) + "</th>" for key in found_columns)
      @columns = []
      for key in found_columns
        # Can't actually do hash literals with variable keys in JavaScript?
        column = {}

        # Make the 'value script' readable as a header.
        # Currently this turns '_.foo.bar.baz' into 'foo<br>bar<br>baz'
        display = key.replace(/\['/g, "<br>").replace(/'\]/g, "").replace("_<br>", "")

        column[display] = key
        @columns.push(column)
        #console.log("Generated columns:", @columns)
  # end generate_columns

  generate_header: (result) ->
    text_columns = []
    for column in @columns
      #console.log("column", column)
      if typeof(column) == "object"
        for name, value of column
          text_columns.push(name)
      else
        text_columns.push(column)
    # end for each @columns
    columns = ("<th>" + @text(key) + "</th>" for key in text_columns)

    header = $("<tr>" + columns + "</tr>").addClass("widget-table-header")
    return header
  # end generate_header

  receive: (result, callback) ->
    if !result? or result.length == 0
      callback(status: 200, message: "No results", null)
      return
    clock = new StopWatch()

    # Generate an HTML table.
    vis = d3.select($("<div>").get(0))
      .append("table")
      .append("tbody")

    # vis[0] is the tbody, we want the table
    table = $(vis[0]).parent()
    # TODO(sissel): Use d3 string formatting.
    
    @generate_columns(result) if !@columns?

    vis.selectAll("tr")
      .data(result)
      .enter()
        .append("tr")
          .classed("widget-table-row", true)
          .html((d) => 
            # TODO(sissel): Special handling for jQuery or HTMLElement objects?
            row = @row(d)
            return row.html()
          )

    # Append header if it was requested.
    table.prepend(@generate_header(result)) if @header 

    $(table).attr("cellspacing", 0)
    $(table).attr("cellpadding", 0)

    # 'vis' appears to be a one-element array containing the div. Turn it into
    # a jquery context before returning.
    $(table).addClass("zebra-striped")
    console.log("Table generation took " + clock.stop() + " seconds")

    callback(null, table)
  # end receive

  detect_columns: (obj, prefix, list) ->
    list = [] if !list?
    prefix = "_" if !prefix?

    for key, value of obj

      # Recurse deeper if necessary.
      if typeof(value) == "object" and !(value instanceof Array)
        @detect_columns(value, prefix + "['" + key + "']", list)
      else
        list.push(prefix + "['" + key + "']")
    return list
  # end detect_columns

  text: (column) ->
    return @column_config[column] ? column
  # end text

  class: (column) ->
    config = @column_config[column]
    return config
  # end class
  
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
          value = eval(value_script)
        else
          value = data[column]

        if typeof(value) != "string"
          value = JSON.stringify(value)
        td = $("<td>").addClass(@class(column)).text(value)
        tr.append(td)
      return tr
    else
      #str = ""
      tr = $("<tr>")
      for key, val of data
        td = $("<td>").addClass(@class(key)).text(val)
        tr.append(td)
      return tr
  # end row
# end class TableChart
  
exports = window.TableChart = TableChart
