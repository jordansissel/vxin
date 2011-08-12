class Widget
  widget: () ->
    # Create a new widget (set of inputs+filters+outputs)

  in: (input) ->
    @input = input
    return this

  out: (output) ->
    @output = output
    return this

  filter: (filter) -> 
    console.log("Widget#filter not yet implemented")
    return this

  append: (selector, callback) ->
    @input.run((data) => 
      output = @output.receive(data)
      #console.log("Input result:", data)
      #console.log("Output result:", output)
      callback(output) if callback?
      $(selector).append(output)
    )
# end class Widget

dothings = () ->
  wtable = new Widget()
#search = new ElasticSearchInput({
#})
#input.search({ 
    #query: "@type:apache",
    #sort_by: "@timestamp"
#})

  table = new TableChart(
    #columns: [ "@timestamp", "@message" ],
    #header: false
    #column_config: {
    #"@timestamp": "timestamp",
    #"@message": "message",
    #}
  )
#wtable.in(input)
#wtable.out(table)
#wtable.append("#table")

# lolpiegraphs
  for i in [1..20]
    input = new ElasticSearchInput()
    pie = new PieChart()
    wpie = new Widget()
    queries = [
      { query: "@type:apache", field: "response" },
      { query: "@type:apache", field: "bytes" },
      { query: "@type:apache", field: "verb" },
      { query: "@type:apache", field: "agent" },
      { query: "@type:apache", field: "referrer" },
      { query: "@type:apache", field: "request" },
    ]

    input.histogram(queries[i % queries.length])
    wpie.in(input)
    wpie.out(pie)
    wpie.append("#content", (element) ->
      console.log(element)
      element
        .css("opacity", Math.random() * 0.1)
        .css("left", Math.random() * 800)
        .css("top", Math.random() * 500 + 50)
        .css("position", "absolute")
      element.animate({ opacity: 1.0 }, Math.random() * 100000)
    )
