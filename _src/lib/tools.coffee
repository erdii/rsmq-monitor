

class Tools
	error: (options) ->
		error = new Error()
		error.message = options.msg
		error.name = options.name if options.name?
		return error

	exec: (cmd, args) ->
		spawn = require("child_process").spawn
		child = spawn(cmd, args)
		return child

	now: () -> Math.floor(Date.now()/1000)

module.exports = new Tools()
