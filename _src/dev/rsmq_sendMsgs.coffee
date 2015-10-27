qconf = require "../queue.json"


async = require "async"
RedisSMQ = require "rsmq"
rsmq = new RedisSMQ qconf.rsmq


async.times 10, ((n, next) ->
	rsmq.sendMessage { qname: qconf.qname, message: "#{n}. Message" }, next
	return), ((err, resps) ->
	if err?
		console.log err
		return

	console.dir resps
	process.exit(0)
	return)
