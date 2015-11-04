_ = require "lodash"
config = require "./lib/config"
express = require "express"
influxconn = require "./lib/influx-connector"
morgan = require "morgan"
pkg = require("../package.json")
rsmqconn = require "./lib/rsmq-connector"
tools = require "./lib/tools"

app = express()

class RMRest extends require("./lib/base")
	constructor: () ->
		super
		@restconfig = config.get("rest")
		# disable x-powered-by HTTP-Header to obscure express server software
		app.disable("x-powered-by")
		# ennable http request logging
		app.use(morgan("dev"))

		@api_v1 = require "./routes/api_v1"
		@api_v1.createRoutes("/api/v1", app)

		# last error catching middleware
		app.use (err, req, res, next) =>
			@logErr err, req
			res.stats(500).send("Internal Server Error")
			return

		@server = app.listen @restconfig, () =>
			@log pkg.name + " ( version #{pkg.version} ) listening at port #{@restconfig.port}"
			return
		return

new RMRest()
