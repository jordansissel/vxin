class StopWatch
  constructor: () ->
    @start()
  # end constructor

  start: () ->
    @start_time = new Date()

  stop: () ->
    @end_time = new Date()
    @duration = (@end_time - @start_time) / 1000.0
    return @duration
# end class StopWatch

# JavaScript, where consistency is a joke.
exports = window.StopWatch = StopWatch
