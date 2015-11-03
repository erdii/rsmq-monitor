RedisSMQ = require "rsmq"
tools = require "./tools"

class RMRConnector extends require("./base")
	constructor: (@options={}) ->
		super
		@rsmq = new RedisSMQ(@options)
		return

	getStats: (qname, cb) =>
		if @rsmq.connected?
			@_getStats(qname, cb)
			return

		@rsmq.on "connect", () ->
			@_getStats(qname, cb)
		return

	_getStats: (qname, cb) =>
		@rsmq.getQueueAttributes {qname: qname}, (err, resp) =>
			if err?
				@logErr(@options, qname, err)
				cb(err)
				return

			cb(null, resp)
			return
		return

module.exports = RMRConnector
