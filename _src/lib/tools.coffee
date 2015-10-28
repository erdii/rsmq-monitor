class RMTools
	exec: (cmd, args) ->
		spawn = require("child_process").spawn
		child = spawn(cmd, args)
		return child

	now: () -> Math.floor(Date.now()/1000)

module.exports = new RMTools()
