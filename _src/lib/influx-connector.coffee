{ log, logErr, debug } = require("./logger")("rsmq-monitor:lib:influx-connector")
_ = require "lodash"
config = require "./config"
errors = require "./errors"
influx = require "influx"

class RMInfluxConnector
	constructor: () ->
		# build a dictionary with relation [key:qname] from queues-config
		queues = config.get "queues"
		@_queues = {}
		@_queues[queue.key] = queue.qname for queue in queues

		# connect to the InfluxDB server
		options = config.get "influx"
		debug "InfluxDB options", options
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
				logErr err
				cb(err)
				return
			debug "success!"
			cb()
			return
		return


	dropStats: (key, cb) =>
		@client.dropMeasurement key, (err, resp) ->
			debug err, resp
			if err?
				# wtf?! dat bug...
				if err.message is "database not open"
					cb(null, resp)
					return
				# wtf is over
				logErr err
				cb(err)
				return
			cb(null, resp)
		return

module.exports = new RMInfluxConnector()
