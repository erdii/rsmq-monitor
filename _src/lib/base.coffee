util = require("util")
debug = require("debug")


class RMBase
	constructor: () ->
		@logKey = @constructor.name
		return
	debug: () =>
		if process.env.NODE_ENV is "development"
			debug( @logKey + if @QKEY? then ":#{@QKEY}" else "" )(arg) for arg in arguments
			return
		else
			return () -> return
		return

	inspect: (arg, i, len) ->
		return util.inspect(arg) + if i+1 < len then "\n" else ""

	log: =>
		console.log "#{(new Date()).toISOString()} #{@logKey}:#{if @QKEY? then @QKEY else ""} " + (@inspect(arg, i, arguments.length) for arg, i in arguments)
		return

	logErr: =>
		console.error "#{(new Date()).toISOString()} #{@logKey}:#{if @QKEY? then "#{@QKEY}:" else ""}ERROR " + (@inspect(arg, i, arguments.length) for arg, i in arguments)
		return

module.exports = RMBase
