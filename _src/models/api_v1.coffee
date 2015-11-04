_ = require "lodash"
config = require "../lib/config"
influxconn = require "../lib/influx-connector"
rsmqconn = require "../lib/rsmq-connector"
tools = require "../lib/tools"

class RMAPIv1Model extends require "../lib/base"
	getAllStats: (key, start, end, group, cb) =>
		influxconn.getStats()
		# <-----------
		return

module.exports = new RMAPIv1Model()
