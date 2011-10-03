$ = jQuery

$(".dropdown").dropdown()
$(".twipsy-hoverable").twipsy()

$("a.output-select.table").click((e) -> 
  console.log("Table chosen")
  # This is a terrible hack.
  window.$$output = TableChart

  if window.$$widget?
    widget = window.$$widget
    widget.out(new TableChart())
    update(widget)
)

$("a.output-select.tree").click((e) -> 
  console.log("tree chosen")
  # This is a terrible hack.
  window.$$output = TreeView
  if window.$$widget?
    widget = window.$$widget
    widget.out(new TreeView())
    update(widget)
)

$("a.output-select.pie").click((e) -> 
  console.log("pie chosen")
  window.$$output = PieChart
  if window.$$widget?
    widget = window.$$widget
    widget.out(new PieChart())
    update(widget)
)

#window.$$output = TableChart unless window.$$output?
window.$$output = TreeView unless window.$$output?
$("form.query").submit((e) => 
  e.preventDefault()

  input = new ElasticSearchInput()
  output = new window.$$output(
    # Temporarily disable specific column selection for now.
    ___columns: [ 
      # TODO(sissel): Permit JSONPath
      # Example of using a 'script' as the value
      # for a column named 'clientip'
      #{ "clientip": "_.clientip" },

      # Example using the same name for header as a property on the data
      #"count"

      # TODO(sissel): instead of { string: string } this needs
      # to be { string: function }
      #
      # like:
      #   { "timestamp": (_) -> v._source["@timestamp"] }
      { "timestamp": "_._source['@timestamp']" }
      { "message": "_._source['@message']" }
    ],
    header: true
  )

  widget = new Widget()
  window.$$widget = widget

  query = $("input[name=query]", e.target).val()
  [query, groupby] = query.split(/\s+BY\s+/)

  settings = {
    query: query
    field: groupby
  }

  if groupby?
    input.histogram(settings)
  else
    input.search(settings)

  widget.in(input)
  widget.out(output)
  update(widget)
)

update = (widget) ->
  $(".loading.throbber").css("opacity", 1)
  clock = new StopWatch(element: $("#status.loading"), label: "Updating...")
  widget.render((error, element) ->
    duration = clock.stop()

    if error?
      # TODO(sissel): Use jquery tmpl or D3 for this.
      alertmsg = $("<div><div class='status'></div><div class='message'></div>")
      message = error.responseText ? error.message
      $(".status", alertmsg).html("Status code: " + error.status)
      $(".message", alertmsg).html("Message: " + message)

      # Use fixed-width if the message appears to be json.
      # TODO(sissel): Use TreeView if the message appears to be JSON.
      if message == "{"
        $(".message", alertmsg).addClass("plain-text")

      alertmsg.addClass("alert-message").addClass("error")
      element = alertmsg
    # end error managment
 
    $("#content").empty().append(element)
    $(".loading.throbber").css("opacity", 0)
    $(".loading.status").text(duration + " seconds")

    # TODO(sissel): Switch this to use CSS transitions?
    # Fade out, clear, and display the new result.
    #$("#content").animate(opacity: 0.0, 200, () =>
      #$("#content").empty().append(element)
      #$("#content").animate(opacity: 1.0, 200,
        #() -> $(".loading.throbber").css("opacity", 0)
      #)
    #) # #content.animate
  ) # widget.redner
# end update
