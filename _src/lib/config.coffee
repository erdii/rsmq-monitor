{ log, logErr, debug } = require("./logger")("rsmq-monitor:lib:config")
_ = require "lodash"
errors = require "./errors"
extend = require "extend"
path = require "path"
tools = require "./tools"

# required keys of objects in config.queues array come here:
requiredQueueKeys = ["key", "qname"]

class RMConfig
	default: () ->
		def =
			influx:
				host: "127.0.0.1"
				port: 8086
				database: "rsmq_monitor"
				username: process.env.DBUSER or null
				password: process.env.DBPASS or null
			queue_defaults:
				host: "127.0.0.1"
				port: 6390
				ns: "rsmq"
				interval: 1
			queues: []
		return def
	constructor: () ->
		# load the local config if the file exists
		try
			_cnf = require path.resolve(__dirname, "../../", process.env.CONF or "config.json")
		catch _err
			throw _err unless err?.code is "MODULE_NOT_FOUND"

		@config = extend true, @default(), _cnf or {}

		unless _.isArray(@config.queues)
			throw errors.create "ETYPE",
				identifier: "config.queues"
				expected: "array"
		for queue, i in @config.queues
			# check existence of required keys
			for requiredQueueKey in requiredQueueKeys
				unless queue.hasOwnProperty(requiredQueueKey)
					throw errors.create "EMISSINGPROPERTY",
						property: requiredQueueKey
						identifier: "config.queues[#{i}]"
			@config.queues[i] = extend true, {}, @config.queue_defaults, queue
		return


	# return config subkey "name" or complete config if no name specified
	# defaults all undefined keys to null
	get: (name = "") =>
		return @config if name is ""
		@config[name] = null if @config[name] is undefined
		return @config[name]

module.exports = new RMConfig()
