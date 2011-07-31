class BarChart # extends Output
  @name = [ "bar" ]

  constructor: () ->
  # end constructor

  display: (settings) ->
    return (channels) =>
      data = channels.data
      console.log("Display", data)
      @show(data[0])
  # end display
  
  show: (data) ->
    xdata = [i.key for i in data] 
    ydata = [i.count for i in data] 
    chart = d3.select("#visual")
      .append("svg:svg")
      .attr("class", "chart")
  # end show
  
# end class ElasticSearchInput

exports = window.BarChart = BarChart
#if module !== undefined
  #module.exports = BarChart

