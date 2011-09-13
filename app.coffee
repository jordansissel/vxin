express = require("express")
app = module.exports = express.createServer()
httpProxy = require("http-proxy")
proxy = new httpProxy.HttpProxy()

# Configuration

app.configure(() ->
  app.set("views", __dirname + "/views")
  app.set("view engine", "jade")
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.compiler(src: __dirname + "/public", enable: ["sass"]))
  app.use(app.router)
  app.use(express.static(__dirname + "/public"))
)

app.configure("development", () ->
  app.use(express.errorHandler(dumpExceptions: true, showStack: true)) 
)

app.configure("production", () ->
  app.use(express.errorHandler()) 
)

# Routes

app.get("/", (req, res) -> 
  res.render("index",
    title: "Express"
  )
)

app.get("/logstash", (req, res) ->
  res.render("logstash",
    title: "logstash",
    style: "logstash.css"
  )
)

app.get("/shell", (req, res) ->
  res.render("shell",
    title: "logstash",
    style: "shell.css"
  )
)

# TODO(sissel): Support SSL, perhaps take a url instead of host, port, etc?
proxythrough = (prefix, host, port) =>
  prefix_re = new RegExp("^" + prefix)
  app.get(new RegExp("^" + prefix + "/.*"), (req, res) =>
    req.url = req.url.replace(prefix_re, "")
    proxy.proxyRequest(req, res, host: host, port: port)
  )

proxythrough("/proxy/elasticsearch", "localhost", 9200)

# TODO(sissel): Figure out how to prompt for authentication and other per
# proxythrough configuration.
#proxythrough("/proxy/loggly", "api.loggly.com", 80)
    
app.listen(3000)
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)
