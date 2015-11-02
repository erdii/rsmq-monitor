{ log, logErr, debug } = require("./logger")("rsmq-monitor:lib:influx-connector")
_ = require "lodash"
config = require "./config"
errors = require "./errors"
influx = require "influx"
sanitize = require "./sanitizer"

class RMInfluxConnector
	constructor: () ->
		# build a dictionary with relation [key:qname] from queues-config
		queues = config.get "queues"
		@_queues = {}
		@_queues[queue.key] = queue.qname for queue in queues

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
				throw errors.create "ETYPE",
					identifier: "data.#{key}"
					expected: "array of objects or object"

		debug "writing stats to influx..."
		@client.writeSeries data, {precision:'s'}, (err) ->
			if err?
				logErr(err)
				cb(err)
				return
			debug "success!"
			cb()
			return
		return

	# getStats(`key`, `opts`, cb)
	# *String* `key`: the rsmq-key, as defined in the cnonfig, to be dropped
	getStats: (key, opts, cb) =>
		if typeof opts is "function"
			cb = opts
			opts = null

		if opts?
			if opts.last?
				querySuffix = " WHERE time > now() - #{sanitize(opts.last)}"
			else if opts.from?
				if opts.until?
					querySuffix = " WHERE time > '#{sanitize(opts.from)}' AND time < '#{sanitize(opts.until)}'"
				else
					querySuffix = " WHERE time > '#{sanitize(opts.from)}'"
		else
			querySuffix = " WHERE time > now() - 24h"

		debug querySuffix
		@client.query "SELECT * FROM #{sanitize(key)}", (err, resp) =>
			if err?
				logErr(err)
				cb(err)
				return

			debug resp[0]
			cb(null, resp[0])
			return
		return

	# dropStats(`key`, cb)
	# *String* `key`: the rsmq-key, as defined in the cnonfig, to be dropped
	dropStats: (key, cb) =>
		@client.dropMeasurement key, (err, resp) ->
			if err?
				# wtf?! dat bug...
				if err.message is "database not open"
					debug "Bug: https://github.com/influxdb/influxdb/issues/4615"
					cb(null, resp)
					return
				debug "error dropping stats"
				logErr(err)
				cb(err)
				return
			cb(null, resp)
		return

	createDatabase: (name, cb) =>
		@client.createDatabase name, (err, result) ->
			if err?
				logErr(err)
				cb(err)
				return

			cb(null, err)
		return


module.exports = new RMInfluxConnector()
