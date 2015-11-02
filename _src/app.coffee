{log, logErr, debug} = ( require("./lib/logger") )("rsmq-monitor:app")

_ = require "lodash"
config = require "./lib/config"
influxconn = require "./lib/influx-connector"
rsmqconn = require "./lib/rsmq-connector"
tools = require "./lib/tools"

queues = config.get("queues")
shards = _.groupBy queues, (q) -> "#{q.host}:#{q.port}:#{q.ns}"

rsmqConnectors = {}
for k, v of shards
	rsmqopts = _.pick(v[0], ["host", "port", "ns"])
	rsmqConnectors[k] = new rsmqconn(rsmqopts)


queryStats = () ->
	debug "queryStats"
	for shardspace, shardqueues of shards
		do (shardspace, shardqueues) ->
			for shardqueue in shardqueues
				do (shardqueue) ->
					debug "\t#{shardqueue.ns}:#{shardqueue.qname}"
					rsmqConnectors[shardspace].getStats shardqueue.qname, (err, resp) ->
						if err?
							process.exit(1)
						resp.qname = shardqueue.qname
						resp.key = shardqueue.key
						resp.ns = shardqueue.ns
						debug resp
						data = {}
						data[shardqueue.key] =
							time: tools.now()
							count: resp.msgs
							sent: resp.totalsent
							recv: resp.totalrecv
						influxconn.writeStats data, (err, resp) ->
							if err?
								process.exit(1)
							return
					return
			return
	return

setInterval queryStats, 1000
