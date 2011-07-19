class ElasticSearchInput # extends Input
  @name = [ "es", "elasticsearch" ]
  @commands = [ "histogram" ]

  constructor: () ->
    console.log("OK")
  # end constructor

  histogram: (settings) ->
    request = {
      "query" : {
        # TODO(sissel): Include query.
        "match_all" : {}
      }, # query
      "facets" : {
        "histo1" : {
          "histogram" : {
            "field" : settings.field 
            "interval" : settings.interval
          } # date_histogram
        } # histo1
      } # facets
    } # request

    return (channels) =>
      @execute("localhost", 9200, request, (data) => 
        # elasticsearch histogram gives us
        @process(data, channels)
      )
  # end histogram
  
  process: (data, channels) ->
    # ElaticSearch results can be like this:
    # {
    #   "hits": {
    #     "hits": [ ... ]
    #   }
    #   "facets": {
    #     "facet name": {
    #       "entries": [ ... ]
    #     }
    #   }
    # }
    console.log(data)
    channels.data.push(data)
  # end process

  execute: (host, port, request, callback) ->
    jQuery.getJSON("http://" + host + ":" + port + "/_search?callback=?",
                   { "source": JSON.stringify(request) },
                   (data, status, xhr) => callback(data, status, xhr))
  # end execute
# end class ElasticSearchInput

es = new ElasticSearchInput()
barchart = new BarChart()

calls = [
  es.histogram({ field: "@timestamp", interval: 60 * 60 * 1000 }),
  barchart.display({})
]

channels = {
  data: [],
  messages: []
}

for func, i in calls
  console.log(i)
  console.log(channels)
  func(channels)

