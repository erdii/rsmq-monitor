qconf = require "./queue.json"


async = require "async"
RedisSMQ = require "rsmq"
rsmq = new RedisSMQ qconf.rsmq
tools = require "../lib/tools"


send = (msg, cb) ->
	rsmq.sendMessage { qname: qconf.qname, message: msg }, (err, resp) ->
		if err?
			console.log err
			cb(err)
			return

		console.dir resp
		cb(null)
		return
	return

msg = (n, offset = 0) -> "#{n}:#{tools.now() - Math.floor(offset/1000)}"

rand = (min, max) -> Math.floor((Math.random()*(max-min) + min)/10)*10

startSending = () ->
	n = 0
	sendAfterTimeout = (err) ->
		return if err?
		n++

		timeout = rand(50, 5000)
		console.log "next msg in #{timeout}ms"
		setTimeout((() ->
			send msg(n, timeout), sendAfterTimeout
			return
		), timeout)
		return

	sendAfterTimeout()
	return

startSending()
