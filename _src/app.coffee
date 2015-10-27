{log, logErr, debug} = ( require("./lib/logger") )("rsmq-monitor:app")
path = require "path"
RedisSMQ = require "rsmq"
RRD = require "./lib/rrd"
tools = require "./lib/tools"

rrdpath = "/var/rrd"
filename = "#{rrdpath}/rsmq-monitor.rrd"
picname = "#{rrdpath}/rsmq-pic.png"

test_rrd = new RRD(filename)

rsmq = new RedisSMQ
	hosthost: "127.0.0.1"
	port: 6379
	ns: "rsmq"

step = 1
interval = step*1000
creation = tools.now() - 10

test_rrd.create step, creation, (err, created_filename) ->
	if err?
		logErr err
		return

	debug filename, created_filename

	startUpdating = () ->
		update = () ->
			rsmq.getQueueAttributes "test", (err, resp) ->
				if err?
					console.log err
					return

				test_rrd.update tools.now(), "mc:rcv:sent", [resp.msgs, resp.totalrecv, resp.totalsent], (err) ->
					if err?
						logErr err
						return

					process.stdout.write "."
					return
				return
			return

		setInterval(update, interval)
		return

	startUpdating()
	return
