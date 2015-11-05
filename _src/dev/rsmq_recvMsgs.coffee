qconf = require "./queue.json"

async = require "async"
RedisSMQ = require "rsmq"
rsmq = new RedisSMQ qconf.rsmq
tools = require "../lib/tools"


receive = (i, cb) ->
	rsmq.receiveMessage { qname: qconf.qnames[i] }, (err, resp) ->
		if err?
			console.log err
			cb(err)
			return

		if resp?.id?
			# console.log "received:", resp
			cb(null, resp)
		else
			cb(null)
		return
	return


del = (i, id, cb) ->
	rsmq.deleteMessage { qname: qconf.qnames[i], id: id }, (err, resp) ->
		if err?
			console.log err
			cb(err)
			return

		if resp is 1
			cb(null, true)
		else
			cb(null, false)
		return
	return


rand = (min, max) -> Math.floor((Math.random()*(max-min) + min)/10)*10


startReceiving = (i) ->
	stopwatch = Date.now()
	counter = 0
	receiveAfterTimeout = () ->
		counter++
		if counter is 101
			diff = Date.now() - stopwatch
			timeperrun = diff / (counter-1)
			runspersecond = Math.round((1000 / timeperrun) * 100) / 100
			console.log "rps: #{runspersecond}"
			counter = 0
			stopwatch = Date.now()
		timeout = 1
		# console.log "next msg in #{timeout}ms"
		setTimeout((() ->
			receive i, (err, resp) ->
				return if err?
				if resp?.id?
					del i, resp.id, (err, success) ->
						return if err?
						receiveAfterTimeout()
						return
				else receiveAfterTimeout()
				return
			return
		), timeout)
		return

	receiveAfterTimeout()
	return

console.dir qconf.qnames
for queue,i in qconf.qnames
	startReceiving(i)
