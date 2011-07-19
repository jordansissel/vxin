class BarChart # extends Output
  @name = [ "bar" ]

  constructor: () ->
  # end constructor

  display: (channels) ->
    data = channels.data
    #points = data["facets"]["histo1"]["entries"]
    console.log(data)
    return () => console.log("Display")
  # end display
# end class ElasticSearchInput

exports = window.BarChart = BarChart
#if module !== undefined
  #module.exports = BarChart

