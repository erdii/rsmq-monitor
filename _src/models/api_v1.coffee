_ = require "lodash"
config = require "../lib/config"
errors = require "../lib/errors"
extend = require "extend"
influxconn = require "../lib/influx-connector"
rsmqconn = require "../lib/rsmq-connector"
tools = require "../lib/tools"

class RMAPIv1Model extends require "../lib/base"
	constructor: () ->
		@queues = config.get("queues")
		super
		return

	packField: (field, group, key) =>
		if group <= @queues[key].interval
			return field
		else
			return "mean(#{field}) as #{field}"

	assembleOpts: (opts, selector, key) ->
		now = tools.now()
		def =
			start: now - 3600
			end: now
			group: 60

		opts = extend({}, def, opts)

		_opts =
			where: "time > #{opts.start}s"

		_opts.where += " AND time < #{opts.end}s" if opts.end?
		_opts.limit = opts.limit if opts.limit?

		switch selector
			when "all"
				_fields = ["count", "recv", "sent"]
			when "count"
				_fields = ["count"]
			when "recv"
				_fields = ["recv"]
			when "sent"
				_fields = ["sent"]

		_opts.fields = ""
		for _field in _fields
			_opts.fields += @packField(_field, opts.group, key) + ", "
		_opts.fields = _opts.fields.slice(0, -2)

		_opts.group = "time(#{opts.group}s)" unless opts.group <= @queues[key].interval
		return _opts

	getStats: (selector) =>
		return (req, cb) =>
			opts = _.pick(req.query, ["start", "end", "group", "limit"])
			key = req.params.key

			if typeof opts is "function"
				cb = opts
				opts = {}
			else
				opts = opts or {}

			_opts = @assembleOpts(opts, selector, key)

			influxconn.getStats key, _opts, (err, resp) =>
				if err?
					cb(err)
					return

				for item, i in resp
					resp[i].time = (new Date(item.time)).valueOf() / 1000

				output =
					opts: _opts
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
