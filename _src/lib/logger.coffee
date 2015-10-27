# USAGE: { log, logErr, debug } = require("./lib/logger")(KEY)

util = require("util")
debug = require("debug")

inspect = (arg, i, len) ->
	return util.inspect(arg) + if i+1 < len then "\n" else ""

module.exports = ( key ) ->
	ret =
		debug: () ->
			if process.env.NODE_ENV is "development"
				debug( key )(arg) for arg in arguments
				return
			else
				return () -> return
			return
		log: ->
			console.log "#{key}: " + (inspect(arg, i, arguments.length) for arg, i in arguments)
			return
		logErr: ->
			console.error key + ":ERROR", arguments
			return

	return ret
