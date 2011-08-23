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
  #pie = new PieChart()
  table = new TableChart(
    columns: [ 
      # Example of using a 'script' as the value
      # for a column named 'clientip'
      { "clientip": "_.clientip" },

      # Example using the same name for header as a property on the data
      "count"
    ]
  )
  widget = new Widget()
  query = {
    query: $("input[name=query]", e.target).val()
    field: "clientip"
  }

  input.histogram(query)
  console.log(input.request)
  widget.in(input)
  widget.out(table)

  $("#content").empty()
  widget.append("#content", (element) ->
    element
      #.css("opacity", Math.random() * 0.5)
      .css("opacity", 0.1)
      #.css("left", Math.random() * 800)
      #.css("top", Math.random() * 500 + 50)
      #.css("position", "absolute")
    #element.animate({ opacity: 1.0 }, Math.random() * 1000)
    element.animate({ opacity: 1.0 }, 200)
  )
)
