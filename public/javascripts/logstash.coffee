$ = jQuery

# click anywhere to hide the current dropdown
$(window).bind("click", (e) ->
  $('a.menu').parent("li").removeClass("open")
)

$("a.menu").click((e) ->
  $(this).parent("li").toggleClass('open')
  return false
)

$("form.query").submit((e) => 
  e.preventDefault()

  input = new ElasticSearchInput()
  table = new TableChart(
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

  query = $("input[name=query]", e.target).val()
  [query, groupby] = query.split(" BY ")

  settings = {
    query: query
    field: groupby
  }

  if groupby?
    input.histogram(settings)
  else
    input.search(settings)

  widget.in(input)
  widget.out(table)

  $(".loading.throbber").css("opacity", 1)
  widget.render((error, element) ->

    if error?
      # TODO(sissel): Use jquery tmpl or D3 for this.
      alertmsg = $("<div><div class='status'></div><div class='message'></div>")
      message = error.responseText ? error.message
      $(".status", alertmsg).html("Status code: " + error.status)
      $(".message", alertmsg).html("Message: " + message)

      if message == "{"
        $(".message", alertmsg).addClass("plain-text")

      alertmsg.addClass("alert-message").addClass("error")
      element = alertmsg
    # end error managment
 
    # TODO(sissel): Switch this to use CSS transitions?
    # Fade out, clear, and display the new result.
    $("#content").animate(opacity: 0.0, 200, () =>
      $("#content").empty().append(element)
      $("#content").animate(opacity: 1.0, 200,
        () -> 
          $(".loading.throbber").css("opacity", 0)
      )
    )
  )
)
