{ log, logErr, debug } = require("./logger")("rsmq-monitor:lib:influx-connector")
config = require "./config"
influx = require "influx"

class RMInfluxConnector
	constructor: () ->
		options = config.get "influx"
		debug options
		@client = influx options

		return

	writeStatsSingle: (unix_ts, key, stats, cb) =>
		stats.time = unix_ts
		@client.writePoint key, stats, null, {precision:'s'}, (err, resp) ->
			if err?
				logErr err
				cb err
				return

			debug resp
			cb null, resp
			return
	return

module.exports = new RMInfluxConnector()
