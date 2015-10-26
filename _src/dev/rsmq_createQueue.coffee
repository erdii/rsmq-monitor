queuename = "moniqueue"


RedisSMQ = require "rsmq"
rsmq = new RedisSMQ { host: "127.0.0.1", port: 6379, ns: "rsmq" }


rsmq.createQueue { qname: queuename }, (err, resp) ->
	if resp is 1
		console.log "#{queuename} created!"
	return
