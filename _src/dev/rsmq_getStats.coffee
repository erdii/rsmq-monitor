
RedisSMQ = require "rsmq"
tools = require "../lib/tools"


qconf = require "./queue.json"
console.dir qconf
rsmq = new RedisSMQ qconf.rsmq


monitor = () ->
	rsmq.getQueueAttributes {qname: qconf.qname}, (err, stats) ->
		if err?
			console.error err
			return

		console.log tools.now() + ":"
		console.log "in queue: #{stats.msgs}"
		console.log "total sent: #{stats.totalsent}"
		console.log "total received: #{stats.totalrecv}"
		console.log "-----------------------------------"
		return
	return

setInterval(monitor, 2000)
