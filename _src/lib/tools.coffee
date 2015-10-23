class Tools
	now: () -> Math.floor(Date.now()/1000)
	exec: (cmd, args, cb_end) ->
		spawn = require("child_process").spawn
		child = spawn(cmd, args)
		stdout = ""
		child.stdout.on "data", (data) ->
			stdout += data.toString()
			return
		child.stdout.on "end", () ->
			cb_end stdout
			return
		return

module.exports = new Tools()
