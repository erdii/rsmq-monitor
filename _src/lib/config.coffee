_ = require "lodash"
errors = require "./errors"
extend = require "extend"
path = require "path"
tools = require "./tools"

# required keys of objects in config.queues array come here:
requiredQueueKeys = ["qname"]

_config = {}

class RMConfig extends require("./base")
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
				port: 6379
				ns: "rsmq"
				interval: 1
			queues: {}
		return def

	constructor: () ->
		super
		# load the local config if the file exists
		try
			_cnf = require path.resolve(__dirname, "../../", process.env.CONF or "config.json")
		catch _err
			throw _err unless err?.code is "MODULE_NOT_FOUND"

		_config = extend true, @default(), _cnf or {}

		unless _.isObject(_config.queues)
			throw errors.create "ETYPE",
				identifier: "config.queues"
				expected: "object"
		for key, queue of _config.queues
			# check existence of required keys
			for requiredQueueKey in requiredQueueKeys
				unless queue.hasOwnProperty(requiredQueueKey)
					throw errors.create "EMISSINGPROPERTY",
						property: requiredQueueKey
						identifier: "config.queues[#{key}]"
			_config.queues[key] = extend true, {}, _config.queue_defaults, queue
		return


	# return config subkey "name" or complete config if no name specified
	# defaults all undefined keys to null
	get: (name = "") =>
		return _config if name is ""
		_config[name] = null if _config[name] is undefined
		return _config[name]

module.exports = new RMConfig()
