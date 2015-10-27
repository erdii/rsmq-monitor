{ log, logErr, debug } = require("./logger")("rsmq-monitor:lib:config")
_ = require "lodash"
extend = require "extend"
path = require( "path" )
tools = require "./tools"

# required keys of objects in config.queues array come here:
requiredQueueKeys = ["key", "qname"]

class Config
	default: () ->
		def =
			rrdtool: "rrdtool"
			dbfolder: "./dbs/"
			queue_default:
				host: "127.0.0.1"
				port: 6390
				ns: "rsmq"
				interval: 1
			queues: []
		return def
	constructor: () ->
		# load the local config if the file exists
		console.log path.resolve( __dirname, "../../" )
		try
			_cnf = require path.resolve( __dirname, "../../", process.env.CONF or "config.json" )
		catch _err
			throw _err unless err?.code is "MODULE_NOT_FOUND"

		@config = extend true, @default(), _cnf or {}

		unless _.isArray(@config.queues)
			throw tools.error
				msg: "config.queues must be an array"
				name: "typeError"
		for queue, i in @config.queues
			# check existence of required keys
			for requiredQueueKey in requiredQueueKeys
				unless queue.hasOwnProperty(requiredQueueKey)
					throw tools.error
						msg: "missing property '#{requiredQueueKey}' in config.queues[#{i}]"
						name: "missingQueueProperty"
			@config.queues[i] = extend true, {}, @config.queue_default, queue
		return


	# return config subkey "name" or complete config if no name specified
	# defaults all undefined keys to null
	get: (name = "") =>
		return @config if name is ""
		@config[name] = null if @config[name] is undefined
		return @config[name]

module.exports = new Config()
