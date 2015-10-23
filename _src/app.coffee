{log, logErr, debug} = require("./lib/logger")("rsmq-monitor:app")
path = require "path"
RRD = require "./lib/rrd"
tools = require "./lib/tools"

rrdpath = "/var/rrds"
filename = "#{rrdpath}/rsmq-monitor.rrd"

test_rrd = new RRD(filename)

step = 1
interval = step*1000

test_rrd.create step, tools.now() - 10, (err, created_filename) ->
	if err?
		logErr err
		return

	debug filename, created_filename

	startUpdating = () ->
		update = (cb) ->
			test_rrd.update tools.now(), "mc:rcv:sent", [10, 10010, 10009], (err) ->
				if err?
					logErr err
					cb(err)
					return
				cb()
			return
		return
	return
