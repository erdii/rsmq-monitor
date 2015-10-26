debug = require("debug")("rsmq-monitor:lib:rsmq-connector")
tools = require "./tools"
RedisSMQ = require "rsmq"

rsmq = null
tools.exec "../sh/gethostip.sh", [], (hostip) =>
	rsmq = new RedisSMQ {host: hostip, port: 6379, ns: "rsmq"}
	console.log "connected"
	return


class Connector
	constructor: () ->
		return

	getStats: (qname, cb) =>
		rsmq.getQueueAttributes qname, (err, resp) ->
			cb(err, resp)
			return
		return

module.exports = new Connector()
