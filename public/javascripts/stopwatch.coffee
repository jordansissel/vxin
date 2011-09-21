class StopWatch
  constructor: (settings) ->
    @element = settings.element 
    @label = settings.label
    @start()
  # end constructor

  start: () ->
    @start_time = new Date()
    @element.text(@label) if @element?

  stop: () ->
    @end_time = new Date()
    @duration = (@end_time - @start_time) / 1000.0
    @element.text(@label + " done: " + @duration) if @element?
    return @duration
# end class StopWatch

# JavaScript, where consistency is a joke.
exports = window.StopWatch = StopWatch
