class VxinLoggly
  constructor: () ->
    console.log("New VxinLoggly")
  # end constructor
    
  run: (args, stdin, context) ->
    console.log("args", args)
    console.log("stdin", stdin)
    console.log("context", context)
    # Currently the loggly 'shell command' stuff requires returning html
    # strings.
    return [$("<div>").append($("<b>testing</b>")).html()]
  # end run
# end class VxinLoggly

loggly.bark.external_command(
  #vxin: new VxinLoggly()
  vxin: 
    run: (args, stdin, context) -> (new VxinLoggly()).run(args, stdin, context)
)
