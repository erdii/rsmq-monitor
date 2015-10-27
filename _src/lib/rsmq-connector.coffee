{ log, logErr, debug } = require("./logger")("rsmq-monitor:lib:rsmq-connector")
RedisSMQ = require "rsmq"
tools = require "./tools"

class Connector
	constructor: () ->
		@rsmq = new RedisSMQ
			host: "127.0.0.1"
			port: 6379
			ns: qconf.ns
		return

	getStats: (qname, cb) =>
		rsmq.getQueueAttributes {qname: qname}, cb
		return

module.exports = new Connector()
