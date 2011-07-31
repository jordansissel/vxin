class ElasticSearchInput # extends Input
  @name = [ "es", "elasticsearch" ]
  @commands = [ "histogram" ]

  constructor: () ->
    console.log("OK")
  # end constructor

  histogram: (settings, callback) ->
    request = {
      "query" : {
        # TODO(sissel): Include query.
        "match_all" : {}
      }, # query
      "facets" : {
        "histo1" : {
        } # histo1
      } # facets
    } # request

    if settings.interval?
      type = "histogram"
      request.facets.histo1 = { 
        "histogram" : {
          "field": settings.field,
          "interval": settings.interval
        }
      }
    else
      type = "terms"
      request.facets.histo1 = {
        "terms": {
          "field": settings.field
        }
      }
    # end if settings.interval?


    # ElasticSearch results can be like this:
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

    @execute("localhost", 9200, request, (data) => 
      console.log("execute data", data)
      switch (type)
        when "terms"
          result = []
          for entry in data.facets.histo1.terms
            result.push({ key: entry.term, count: entry.count })
        when "histogram"
          result = data.facets.histo1.entries
      callback(result)
    )
  # end histogram

  execute: (host, port, request, callback) ->
    jQuery.getJSON("http://" + host + ":" + port + "/_search?callback=?",
                   { "source": JSON.stringify(request) },
                   (data, status, xhr) => callback(data, status, xhr))
  # end execute
# end class ElasticSearchInput

es = new ElasticSearchInput()
pie = new PieChart()

#es.histogram({ field: "@timestamp", interval: 60 * 60 * 1000 }, (data) =>
es.histogram({ field: "verb" }, (data) =>
  pie.receive(data)
)
