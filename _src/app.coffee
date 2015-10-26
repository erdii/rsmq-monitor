{log, logErr, debug} = ( require("./lib/logger") )("rsmq-monitor:app")
path = require "path"
RRD = require "./lib/rrd"
tools = require "./lib/tools"

rrdpath = "/var/rrd"
filename = "#{rrdpath}/rsmq-monitor.rrd"
picname = "#{rrdpath}/rsmq-pic.png"

test_rrd = new RRD(filename)

step = 1
interval = step*1000
creation = tools.now() - 10

test_rrd.create step, creation, (err, created_filename) ->
	if err?
		logErr err
		return

	debug filename, created_filename

	startUpdating = () ->
		msgs = 10
		rcv = 10010
		snt = 10009
		update = () ->
			test_rrd.update tools.now(), "mc:rcv:sent", [msgs, rcv, snt], (err) ->
				if err?
					logErr err
					return

				msgs += 1
				rcv += 100
				snt += 2*msgs
				process.stdout.write "."

				now = tools.now()
				test_rrd.graph picname, { cf: "LAST", start: now - 60 }, (out) ->
					process.stdout.write ","
					return
				return
			return

		setInterval(update, interval)
		return

	startUpdating()
	return
