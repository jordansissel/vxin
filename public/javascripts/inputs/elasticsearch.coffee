class ElasticSearchInput # extends Input
  @name = [ "es", "elasticsearch" ]
  @commands = [ "histogram" ]

  constructor: () ->
    #console.log("OK")
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
  
  search: (settings) ->
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
    @process = (data) => data.hits.hits
  # end search

  run: (callback) -> 
    if @cached_result?
      callback(@cached_result)
      return
    
    @execute(@request, (data) =>
      @cached_result = @process(data)
      callback(@cached_result)
    )
  # end run

  execute: (request, callback) ->
    #console.log("Elasticsearch Request:", request)
    # For elasticsearch REST/JSON API to work well, we need a same-server
    # handler that proxies to elasticsearch. Otherwise we have to use <script>
    # or other lame hacks and we don't get nice error reporting.
    # TODO(sissel): Make the path tunable; allow folks to talk directly
    # to elasticsearch at the risk of no error reporting.
    # TODO(sissel): use jQuery.ajax and support timeouts
    req = jQuery.getJSON("/proxy/elasticsearch/_search",
                         { "source": JSON.stringify(request) },
                         (data, status, xhr) => callback(data, status, xhr))
    req.error((e) -> console.log("Error in elasticsearch request", e))
  # end execute
# end class ElasticSearchInput

# JavaScript, where consistency is a joke.
exports = window.ElasticSearchInput = ElasticSearchInput
