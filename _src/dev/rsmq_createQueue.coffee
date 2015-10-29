qconf = require "./queue.json"



RedisSMQ = require "rsmq"
rsmq = new RedisSMQ qconf.rsmq


rsmq.createQueue { qname: qconf.qname }, (err, resp) ->
	if resp is 1
		console.log "#{qconf.qname} created!"
	process.exit(0)
	return
