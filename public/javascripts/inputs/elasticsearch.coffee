class ElasticSearchInput # extends Input
  @name = [ "es", "elasticsearch" ]
  @commands = [ "histogram" ]

  constructor: () ->
    #console.log("OK")
  # end constructor

  histogram: (settings, callback) ->
    #console.log("Settings:", settings)
    request = {
      "query" : {
        "query_string": {
          "query": settings.query || "*",
          "default_operator": "AND"
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
      # TODO(sissel): Allow specifying a 'script field' too
      # TODO(sissel): Allow specifying composite fields (like 'request,response')
      request.facets.histo1 = { 
        "histogram" : {
          "field": settings.field,
          "interval": settings.interval
        }
      }
    else
      # Otherwise ask for a terms facet.
      type = "terms"
      # TODO(sissel): Allow specifying a 'script field' too
      # TODO(sissel): Allow specifying composite fields (like 'request,response')
      request.facets.histo1 = {
        "terms": {
          "field": settings.field
        }
      }
      console.log("request", request)
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
    #console.log("Request", request)
    @process = (data) => 
      # TODO(sissel): just make methods for this 'process_histogram' etc
      switch (type)
        when "terms"
          result = []
          for entry in data.facets.histo1.terms
            # TODO(sissel): Not sure how to make coffeescript take a variable
            # as a key.
            row = { count: entry.count }
            row[settings.field] = entry.term
            result.push(row)
            #result.push({ key: entry.term, count: entry.count })
        when "histogram"
          result = data.facets.histo1.entries
      return result
  # end histogram
  
  count: (settings) ->
    # The count API just supports the Query language.
    request = {
      "query_string": {
        "query": settings.query || "*"
      } # query_string
    } # request

    @request = request
    @process = (data) => 
      #console.log("Result:", data)
      return [ "key": settings.query, "count": data.count ]
    @path = "/_count"
  # end count

  search: (settings) ->
    request = {
      "size": settings.size || 50,
      "from": settings.from || 0,
      "query": {
        "query_string": {
          "query": settings.query || "*"
        } # query_string
      }, # query
    } # request

    if settings.sort_by?
      request.sort = [ settings.sort_by ]
    # end if settings.sort_by?

    @request = request
    @process = (data) => data.hits.hits
  # end search

  run: (callback) -> 
    clock = new StopWatch(element: $("#status.loading"),
      label: "Querying ElasticSearch")
    if @cached_result?
      console.log("Using cached result")
      console.log("ElasticSearch input took " + clock.stop() + " seconds")
      callback(null, @cached_result)
      return
    
    @execute(@request, (error, data) =>
      console.log("ElasticSearch input took " + clock.stop() + " seconds")
      # Skip processing and caching of data if there is no data.
      @cached_result = @process(data) unless error?
      callback(error, @cached_result)
    )
  # end run

  execute: (request, callback) ->
    @path ?= "/_search"
    #console.log("Elasticsearch Request:", request)
    # For elasticsearch REST/JSON API to work well, we need a same-server
    # handler that proxies to elasticsearch. Otherwise we have to use <script>
    # or other lame hacks and we don't get nice error reporting.
    # TODO(sissel): Make the path tunable; allow folks to talk directly
    # to elasticsearch at the risk of no error reporting.
    # TODO(sissel): use jQuery.ajax and support timeouts
    path = "/proxy/elasticsearch" + @path

    console.log("ElasticSearch", path: path, request: request)

    req = jQuery.getJSON(path
                         { "source": JSON.stringify(request) },
                         (data, status, xhr) => callback(null, data))
    req.error((error) => 
      console.log("Error in elasticsearch request", error)
      if error.responseText[0] == "{"
        # assume response error is json, format it sanely.
        obj = JSON.parse(error.responseText)
        error.responseText = JSON.stringify(obj, null, 2)
      callback(error, null)
    )
  # end execute
# end class ElasticSearchInput

# JavaScript, where consistency is a joke.
exports = window.ElasticSearchInput = ElasticSearchInput
