_ = require "lodash"
config = require "./config"
errors = require "./errors"
influx = require "influx"
tools = require "./tools"

class RMInfluxConnector extends require("./base")
	constructor: () ->
		super
		# connect to the InfluxDB server
		options = config.get "influx"
		@client = influx options
		return

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
			if _.isArray(measurement)
				for sample, i in measurement
					measurement[i] = [sample]
			else if _.isObject(measurement)
				data[key] = [[measurement]]
			else
				cb errors.create "ETYPE",
					identifier: "data.#{key}"
					expected: "array of objects or object"
				return

		@client.writeSeries data, {precision:'s'}, (err) =>
			if err?
				@logErr(err)
				cb(err)
				return
			cb()
			return
		return

	# getStats(`key`, `opts`, cb)
	# *String* `key`: the rsmq-key, as defined in the cnonfig, to be dropped
	getStats: (key, opts, cb) =>
		if typeof opts is "function"
			cb = opts
			opts = null

		queryInfix = "count, DERIVATIVE()"

		if opts?
			if opts.start? and opts.end?
				querySuffix = "WHERE time > '#{tools.sanitize(opts.from)}' AND time < '#{tools.sanitize(opts.end)}'"
			else
				if opts.start?
					# querySuffix = "WHERE time > now() - #{tools.sanitize(opts.end)}"
					querySuffix = "WHERE time > '#{tools.sanitize(opts.start)}'"
				else if opts.end?
					querySuffix = "WHERE time < '#{tools.sanitize(opts.start)}'"
				else
					querySuffix = "WHERE time > now() - 24h"
			if opts.group?
				querySuffix += " GROUP BY #{opts.group}"
				queryInfix = "MEAN(count) as mCount,MEAN(received)"
		else
			querySuffix = "WHERE time > now() - 24h"
		# <-----------
		# <-----------
		# <-----------
		# <-----------
		@debug querySuffix
		@client.query "SELECT #{queryInfix} FROM #{tools.sanitize(key)} #{querySuffix}", (err, resp) =>
			if err?
				@logErr(err)
				cb(err)
				return

			# TODO check resp
			@debug resp
			@debug resp[0]
			cb(null, resp[0])
			return
		return

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
				@logErr(err)
				cb(err)
				return
			cb(null, resp)
		return

	createDatabase: (name, cb) =>
		@client.createDatabase name, (err, resp) =>
			cb(null, resp)
		return


module.exports = new RMInfluxConnector()
