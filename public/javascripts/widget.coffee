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

  append: (selector) ->
    @input.run((data) => 
      console.log("Input result:", data)
      output = @output.receive(data)
      console.log("Output result:", output)
      #$(output).addClass("box")
      $(selector).append(output)
    )
    return this
# end class Widget

wtable = new Widget()
wpie = new Widget()
input = new ElasticSearchInput()
#search = new ElasticSearchInput({
#})
#search.search({ 
  #query: "@type:apache",
  #sort_by: "@timestamp"
#})
request = { 
  query: "@type:apache",
  field: "response"
  #sort_by: "@timestamp"
}
input.histogram(request)

pie = new PieChart()

table = new TableChart()
wtable.in(input)
wtable.out(table)
wtable.append("#content")

wpie.in(input)
wpie.out(pie)
wpie.append("#content")
