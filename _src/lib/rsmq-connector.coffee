{ log, logErr, debug } = require("./logger")("rsmq-monitor:lib:rsmq-connector")
RedisSMQ = require "rsmq"
tools = require "./tools"

class RMRConnector
	constructor: (options) ->
		@options = options
		@rsmq = new RedisSMQ(options)
		return

	getStats: (qname, cb) =>
		@rsmq.getQueueAttributes {qname: qname}, (err, resp) =>
			if err?
				logErr(@options, qname, err)
				cb(err)
				return

			cb(null, resp)
		return

module.exports = RMRConnector
