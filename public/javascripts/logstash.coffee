jQuery("form#query").submit((e) => 
  e.preventDefault()


  input = new ElasticSearchInput()
  #pie = new PieChart()
  table = new TableChart()
  widget = new Widget()
  query = {
    query: jQuery("input[name=query]", e.target).val()
    field: "referrer"
  }

  input.count(query)
  console.log(input.request)
  widget.in(input)
  widget.out(table)

  jQuery("#content").empty()
  widget.append("#content", (element) ->
    console.log(query)
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
