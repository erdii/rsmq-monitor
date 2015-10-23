{log, logErr, debug} = require("./lib/logger")("rsmq-monitor:app")
rrd = require "node_rrd"
tools = require "./tools"

class RRD
	constructor: (filename) ->
		debug "Filename: #{filename}"
		@filename = filename
		return

	create: (step, starttime, cb) =>
		rrd.create @filename, step, starttime,
			[
				# TODO calculate RRA length etc... dynamical
				"DS:mc:GAUGE:2:0:U"
				"DS:rcv:COUNTER:2:0:U"
				"DS:sent:COUNTER:2:0:U"
				"RRA:LAST:0.5:1:3600"
				"RRA:AVERAGE:0.5:60:60"
				"RRA:MAX:0.5:60:60"
				"RRA:MIN:0.5:60:60"
			],
			(err) ->
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

	graph: (picname, options, cb) =>
		tools.exec "rrdtool", [
			"graph"
			picname
			"DEF:msgs=#{@filename}:rcv:" + options.cf
			"DEF:rcvmsgs=#{@filename}:rcv:" + options.cf
			"DEF:sentmsgs=#{@filename}:sent:" + options.cf
			"LINE2:msgs#00FF00"
			"LINE1:rcvmsgs#FF0000"
			"LINE1:rcvmsgs#0000FF"
			"--end"
			"now"
			"--start"
			options.start ], (stdout) ->
				debug "'#{stdout}'" unless stdout is "481x141\n"
				cb(stdout)
				return
		return

module.exports = RRD
