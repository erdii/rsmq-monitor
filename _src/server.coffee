express = require "express"
app = express()

rrd = new ( require( "./lib/rrd" ) )( "/var/rrd/rsmq-monitor.rrd" )

app.get "/graph", (req, res)->
	_opt =
		cf: "LAST"
		start: "now-10000"
	rrd.graph(_opt).stdout.pipe res
	return

server = app.listen 8080, () ->
	host = server.address().address
	port = server.address().port
	console.log "Example app listening at http://%s:%s", host, port
	return
