qconf = require "./queue.json"


async = require "async"
RedisSMQ = require "rsmq"
rsmq = new RedisSMQ qconf.rsmq
tools = require "../lib/tools"


send = (msg, i, cb) ->
	rsmq.sendMessage { qname: qconf.qnames[i], message: msg }, (err, resp) ->
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

startSending = (i) ->
	n = 0
	sendAfterTimeout = (err) ->
		process.exit(1) if err?
		n++

		timeout = rand(10, 50)
		console.log "next msg in #{timeout}ms"
		setTimeout((() ->
			send(msg(n, timeout), i, sendAfterTimeout)
			return
		), timeout)
		return

	sendAfterTimeout()
	return

console.dir qconf.qnames
for queue,i in qconf.qnames
	console.log "#{i}: #{queue}"
	startSending(i)
