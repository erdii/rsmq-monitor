_ = require "lodash"
async = require "async"
config = require "./config"
errors = require "./errors"
extend = require "extend"
influx = require "influx"
tools = require "./tools"

class RMInfluxConnector extends require("./base")
	constructor: () ->
		super
		# connect to the InfluxDB server
		options = config.get "influx"
		@client = influx options
		@queues = config.get "queues"
		return

	assembleOpts: (opts, selector, key) ->
		@debug opts, selector, key

		now = tools.now()
		def =
			start: now - 3600
			end: now
			group: 60

		opts = extend({}, def, opts)

		_opts = {}
		_opts.fields = ""
		_opts.limit = opts.limit if opts.limit?
		return [_opts, opts] if opts.wildcard

		_opts.where = "time > #{opts.start}s"

		_opts.where += " AND time < #{opts.end}s" if opts.end?

		switch selector
			when "all"
				_fields = ["count", "recv", "sent"]
			when "count"
				_fields = ["count"]
			when "recv"
				_fields = ["recv"]
			when "sent"
				_fields = ["sent"]

		for _field in _fields
			_opts.fields += @packField(_field, opts.group, key) + ", "
		_opts.fields = _opts.fields.slice(0, -2)

		_opts.group = "time(#{opts.group}s)" unless opts.group <= @queues[key].interval
		return [_opts, opts]

	# dropStats(`key`, cb)
	# *String* `key`: the rsmq-key, as defined in the config, to be dropped
	dropStats: (key, cb) =>
		@client.dropMeasurement key, (err, resp) =>
			if err?
				# wtf?! dat bug...
				if err.message is "database not open"
					@debug "Bug: https://github.com/influxdb/influxdb/issues/4615"
					cb(null, resp)
					return
				@debug "error dropping stats"
				cb(err)
				return
			cb(null, resp)
		return

	# getStats(`key`, `selector` `_opts`, cb)
	getStats: (key, selector, _opts, cb) =>
		if typeof _opts is "function"
			cb = _opts
			_opts = {}

		[opts, opts_raw] = @assembleOpts(_opts, selector, key)

		opts.fields = tools.sanitize(opts.fields or "*")
		querySelect = "SELECT #{tools.sanitize(opts.fields)} "
		queryWhere = if opts.where? then " WHERE #{tools.sanitize(opts.where)}" else ""
		queryGroup = if opts.group? then " GROUP BY #{tools.sanitize(opts.group)}" else ""
		queryLimit = if opts.limit? then " LIMIT #{tools.sanitize(opts.limit)}" else ""

		queryString = querySelect + "FROM #{key}" + queryWhere + queryGroup + queryLimit
		@debug queryString
		@client.query queryString, (err, resp) =>
			@debug err, resp
			if err?
				cb(err)
				return

			unless _.isArray(resp) and resp[0]?
				cb errors.create "EINVALIDRESPONSE",
					from: "InfluxDB"
					resp: resp
				return

			@debug "answer length: #{resp[0].length}"
			cb(null, resp[0], opts_raw)
			return
		return

	packField: (field, group, key) =>
		if group <= @queues[key].interval
			return field
		else
			return "mean(#{field}) as #{field}"

	# writeStats(`data`, cb)
	# *object* `data`: {
	#   `key`: [
	#     *object* `sample`,
	#     ...
	#   ],
	#   ...
	# }
	# * `data` contains either an array of `samples` or a single `sample` for each queue (identified by `key`) for which you want to send `samples`:
	# * `key`: the queue's key - as defined in config.json
	# * *array* `sample`
	#     * `sample`: an object in the following form:
	#         * `time`: the unix timestamp that defines the measurement time
	#         * `count`: the number of messages currently in the queue
	#         * `sent`: total number of messages ever sent to the queue
	#         * `recv`: total number of messages ever received by workers
	writeStats: (data, cb) =>
		for key, measurement of data
			tags = { interval: @queues[key]?.interval or null }
			if _.isArray(measurement)
				for sample, i in measurement
					measurement[i] = [sample, tags]
			else if _.isObject(measurement)
				data[key] = [[measurement, tags]]
			else
				cb errors.create "ETYPE",
					identifier: "data.#{key}"
					expected: "array of objects or object"
				return

		@client.writeSeries data, {precision:'s'}, (err) =>
			if err?
				cb(err)
				return
			cb()
			return
		return


module.exports = new RMInfluxConnector()
