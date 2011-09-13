class Widget
  widget: () ->
    # Create a new widget (set of inputs+filters+outputs)

  in: (input) ->
    @input = input
    return this
  # end in

  out: (output) ->
    @output = output
    return this
  # end out

  filter: (filter) -> 
    console.log("Widget#filter not yet implemented")
    return this
  # end filter

  render: (callback) ->
    throw "Widget#render not called with callback" if !callback?

    @input.run((error, data) => 
      if error?
        callback(error)
      else
        @output.receive(data, callback)
    )
  # end render 

  append: (selector, callback) ->
    render((element) =>
      callback(output) if callback?
      $(selector).append(output)
    )
  # end append 
# end class Widget

exports = window.Widget = Widget

#console.log("OK")
#
#input = new ElasticSearchInput()
#pie = new PieChart()
#wpie = new Widget()
#queries = [
  #{ query: "@type:apache", field: "response" },
  #{ query: "@type:apache", field: "bytes" },
  #{ query: "@type:apache", field: "verb" },
  #{ query: "@type:apache", field: "agent" },
  #{ query: "@type:apache", field: "referrer" },
  #{ query: "@type:apache", field: "request" },
#]
#
#input.histogram(queries[i % queries.length])
#wpie.in(input)
#wpie.out(pie)
#wpie.append("#content", (element) ->
  #console.log(element)
  #element
    #.css("opacity", Math.random() * 0.5)
    #.css("left", Math.random() * 800)
    #.css("top", Math.random() * 500 + 50)
    #.css("position", "absolute")
  #element.animate({ opacity: 1.0 }, Math.random() * 100000)
#)

