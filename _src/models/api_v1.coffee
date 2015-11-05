_ = require "lodash"
config = require "../lib/config"
influxconn = require "../lib/influx-connector"
rsmqconn = require "../lib/rsmq-connector"
tools = require "../lib/tools"

class RMAPIv1Model extends require "../lib/base"
	constructor: () ->
		super
		@queues = config.get("queues")
		return

	getAllStats: (key, start="now() - 1h", end="", group="1m", limit="", cb) =>
		opts =
			fields: "mean(count) as count, mean(recv) as recv, mean(sent) as sent"
			where: "time > #{start}"
			group: "time(#{group})"
		opts.where += " AND time < #{end}" if end.length
		opts.limit = limit if limit.length
		influxconn.getStats key, opts, (err, resp) =>
			if err?
				cb(err)
				return

			output =
				key: key
				opts: opts
				interval: @queues[key].interval
				items: resp
			cb(null, output)
			return
		return

module.exports = new RMAPIv1Model()
