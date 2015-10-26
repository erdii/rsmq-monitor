async = require "async"
RedisSMQ = require "rsmq"
rsmq = new RedisSMQ { host: "127.0.0.1", port: 6379, ns: "rsmq" }

queuename = "moniqueue"

async.times 10, ((n, next) ->
	rsmq.sendMessage { qname: queuename, message: "#{n}. Message" }, next
	return), ((err, resps) ->
	if err?
		console.log err
		return

	console.dir resps
	process.exit(0)
	return)
