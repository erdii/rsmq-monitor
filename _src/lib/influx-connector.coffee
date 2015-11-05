_ = require "lodash"
async = require "async"
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
		@queues = config.get "queues"
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
			tags = { interval: @queues[key].interval }
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
			opts = {}

		opts.fields = tools.sanitize(opts.fields or "*")
		querySelect = "SELECT #{tools.sanitize(opts.fields)} "
		queryWhere = if opts.where? then " WHERE #{tools.sanitize(opts.where)}" else ""
		queryGroup = if opts.group? then " GROUP BY #{tools.sanitize(opts.group)}" else ""
		queryLimit = if opts.limit? then " LIMIT #{tools.sanitize(opts.limit)}" else ""

		queryString = querySelect + "FROM #{key}" + queryWhere + queryGroup + queryLimit
		@debug queryString
		@client.query queryString, (err, resp) =>
			if err?
				@logErr(err)
				@debug err
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

	maintainContinuousQueries: (cb) =>
		queues = config.get("queues")
		fields = ["sent", "recv"]
		archives = [["1s", "60s"], ["1m", "60m"], ["1h", "24h"], ["1d", "31d"], ["4w", "48w"]]
		@client.getContinuousQueries (err, continuousQueries) =>
			if err?
				cb(err)
				return

			assemble = (key, field, archive) -> key + "_" + field + "_" + archive[0] + archive[1]

			cqs = _.pluck(continuousQueries[0], "name")
			renew = {}
			for key of queues
				for field in fields
					for archive in archives
						ass = assemble(key, field, archive)
						if cqs.indexOf(ass) is -1
							renew[ass] = [key, "DERIVATIVE(#{field}, #{archive[0]})", archive[1]]

			@debug "all continuousQueries are there - nothing to maintain" if Object.keys(renew).length is 0
			async.forEachOfSeries renew, ((cqparams, cqkey, cbA) =>
				queryString = "SELECT #{cqparams[1]} INTO #{cqkey} FROM #{cqparams[0]} GROUP BY time(#{cqparams[2]})"
				@debug queryString
				# cbA()
				@client.createContinuousQuery cqkey, queryString, (err, resp) =>
					if err?
						cbA(err)
						return

					@debug resp
					cbA()
					return
				return), (err) =>
					if err?
						cb(err)
						return

					cb()
				return
			return
		return


module.exports = new RMInfluxConnector()
