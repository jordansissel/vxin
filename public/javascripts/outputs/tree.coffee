class TreeView # extends Output
  @name = [ "tree" ]

  constructor: (settings) ->
    settings ?= {}
  # end constructor

  receive: (result, callback) ->
    if !result? or result.length == 0
      callback(status: 200, message: "No results", null)
      return

    # Generate an HTML table.
    vis = d3.select($("<div>").get(0))
      .append("ul")

    vis.selectAll("li")
      .data(result)
      .enter()
        .append("li")
          .classed("widget-tree-row", true)
          .html((d) => 
            # TODO(sissel): Special handling for jQuery or HTMLElement objects?
            # This is a lame Hack: return html because that's what D3 wants.
            row = @row(d).html()
            return row
          )
    # end vis.selectAll

    # 'vis' appears to be a one-element array containing the div. Turn it into
    # a jquery context before returning.
    el = $(vis[0])
    $(el).find("li.widget-tree-row").addClass("zebra-striped")
    # TODO(sissel): make D3 take HTML elements instead of html text so I
    # can do this click handler in the @row method
    $(".reveal-sibling", el).click((e) -> 
      $(e.target).siblings().toggleClass("hidden-by-default")
    )
    callback(null, el)
  # end receive

  row: (data) ->
    list = $("<ul>").addClass("zebra-striped")
    for key, val of data
      item = $("<li>")
      dl = $("<dl>")
      if typeof(val) != "object"
        dt = $("<dt></dt>").text(key)
        dd = $("<dd></dd>").text(val)
      else
        dt = $("<dt></dt>").text(key + " >>")
        dd = $("<dd></dd>")
        # recurse
        dd.append(@row(val))
        # hide nested objects by default.
        dt.addClass("reveal-sibling")
        dd.addClass("hidden-by-default")
      # end string check
      dl.append(dt)
      dl.append(dd)
      item.append(dl)
      # end string check
      list.append(item)
    return list
  # end row
# end class TreeView
  
exports = window.TreeView = TreeView
