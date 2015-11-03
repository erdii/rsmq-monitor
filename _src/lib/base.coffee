util = require("util")
debug = require("debug")


class RMLogger
	constructor: () ->
		@logKey = @constructor.name
		return
	debug: () =>
		if process.env.NODE_ENV is "development"
			debug( @logKey )(arg) for arg in arguments
			return
		else
			return () -> return
		return

	inspect: (arg, i, len) ->
		return util.inspect(arg) + if i+1 < len then "\n" else ""

	log: =>
		console.log "#{(new Date()).toISOString()} #{@logKey}: " + (@inspect(arg, i, arguments.length) for arg, i in arguments)
		return

	logErr: =>
		console.error "#{(new Date()).toISOString()} #{@logKey}:ERROR: " + (@inspect(arg, i, arguments.length) for arg, i in arguments)
		return

module.exports = RMLogger
