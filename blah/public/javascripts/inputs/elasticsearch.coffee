class ElasticSearchInput # extends Input
  @name = [ "es", "elasticsearch" ]
  @commands = [ "histogram" ]

  constructor: () ->
    console.log("OK")
  # end constructor

  histogram: (settings, callback) ->
    request = {
      "query" : {
        "query_string": {
          "query": settings.query || "*"
        }
      }, # query
      "facets" : {
        "histo1" : {
        } # histo1
      } # facets
    } # request

    settings.size ?= 10

    if settings.interval?
      # If given an interval, ask elasticsearch for a histogram
      type = "histogram"
      request.facets.histo1 = { 
        "histogram" : {
          "field": settings.field,
          "interval": settings.interval
        }
      }
    else
      # Otherwise ask for a terms facet.
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

    @request = request
    #@execute("localhost", 9200, request, (data) => 
    @process = (data) => 
      switch (type)
        when "terms"
          result = []
          for entry in data.facets.histo1.terms
            result.push({ key: entry.term, count: entry.count })
        when "histogram"
          result = data.facets.histo1.entries
      return result
  # end histogram
  
  search: (settings, callback) ->
    request = {
      "size": settings.size || 50,
      "from": settings.from || 0,
      "query" : {
        "query_string": {
          "query": settings.query || "*"
        }
      }, # query
    } # request

    if settings.sort_by?
      request.sort = [ settings.sort_by ]
    # end if settings.sort_by?

    @request = request
    @process = (data) => callback(data.hits.hits)
    #@execute("localhost", 9200, request, (data) =>
      #callback(data.hits.hits)
    #)
  # end search

  run: (callback) -> 
    if @cached_result?
      callback(@cached_result)
      return
    
    @execute("localhost", 9200, @request, (data) =>
      #console.log("es run result:", data.hits.hits)
      @cached_result = @process(data)
      callback(@cached_result)
    )
  # end run

  execute: (host, port, request, callback) ->
    console.log("Elasticsearch Request:", request)
    jQuery.getJSON("http://" + host + ":" + port + "/_search?callback=?",
                   { "source": JSON.stringify(request) },
                   (data, status, xhr) => callback(data, status, xhr))
  # end execute
# end class ElasticSearchInput

#es = new ElasticSearchInput()
#pie = new PieChart()
#table = new TableChart()

#es.histogram({ field: "@timestamp", interval: 60 * 60 * 1000 }, (data) =>
#es.histogram({ field: "clientip" }, (data) =>
  #pie.receive(data)
#)
#es.search({ query: "*", sort_by: "@timestamp" }, (data) =>
  #table.receive(data)
#)

exports = window.ElasticSearchInput = ElasticSearchInput
