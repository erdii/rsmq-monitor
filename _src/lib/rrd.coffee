{log, logErr, debug} = require("./logger")("rsmq-monitor:app")
rrd = require "node_rrd"
tools = require "./tools"

class RRD
	constructor: (filename) ->
		debug "Filename: #{filename}"
		@filename = filename
		return

	create: (step, cb) =>
		rrd.create @filename, step, tools.now() - 10,
			[
				# TODO calculate RRA length etc... dynamical
				"DS:mc:GAUGE:2:0:U"
				"DS:rcv:COUNTER:2:0:U"
				"DS:sent:COUNTER:2:0:U"
				"RRA:LAST:0.5:1:3600"
			],
			(err) =>
				if err?
					cb(err)
					return

				debug "RRD #{@filename} created!"
				cb(null, @filename)
				return
		return

	update: (timestamp, template, data, cb) =>
		predata = [timestamp]
		Array.prototype.push.apply(predata, data)
		_data = [predata.join(':')]
		debug "Updating #{@filename} with", _data
		rrd.update @filename, template, _data, cb
		return

	graph: (options) =>
		graph = tools.exec "rrdtool", [
			"graph"
			"-"
			"--title=RSMQ-Monitor"
			"--vertical-label=Msgs"
			"DEF:msgs=#{@filename}:mc:" + options.cf
			"DEF:rcvmsgs=#{@filename}:rcv:" + options.cf
			"DEF:sentmsgs=#{@filename}:sent:" + options.cf
			"LINE2:msgs#00FF00:Messages in queue"
			"LINE1:rcvmsgs#FF0000:Received Msgs/Sec"
			"LINE1:sentmsgs#0000FF:Sent Msgs/Sec"
			"--start"
			options.start
			"--end"
			"now"
			]
		return graph

module.exports = RRD
