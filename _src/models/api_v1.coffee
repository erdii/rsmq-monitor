_ = require "lodash"
config = require "../lib/config"
errors = require "../lib/errors"
influxconn = require "../lib/influx-connector"
rsmqconn = require "../lib/rsmq-connector"
tools = require "../lib/tools"

class RMAPIv1Model extends require "../lib/base"
	constructor: () ->
		@queues = config.get("queues")
		super
		return



	getStats: (selector) =>
		return (req, cb) =>
			opts = _.pick(req.query, ["start", "end", "group", "limit"])
			key = req.params.key

			if typeof opts is "function"
				cb = opts
				opts = {}
			else
				opts = opts or {}

			influxconn.getStats key, selector, opts, (err, resp, opts_raw) =>
				if err?
					cb(err)
					return

				for item, i in resp
					resp[i].time = (new Date(item.time)).valueOf() / 1000

				output =
					opts: opts_raw
					items: resp
				cb(null, output)
				return
			return


	getAllStats: (req, cb) =>
		@getStats("all")(req, cb)
		return

	getCount: (req, cb) =>
		@getStats("count")(req, cb)
		return

	getReceived: (req, cb) =>
		@getStats("recv")(req, cb)
		return

	getSent: (req, cb) =>
		@getStats("sent")(req, cb)
		return


	listQueues: (req, cb) =>
		cb(null, @queues)
		return

module.exports = new RMAPIv1Model()
