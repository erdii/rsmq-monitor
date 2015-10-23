debug = require("debug")("rsmq-monitor:lib:rsmq-connector")
exec = require "./cmd_exec"
RedisSMQ = require "rsmq"

rsmq = null
exec "../sh/gethostip.sh", [], (me) =>
	hostip = me.stdout
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
