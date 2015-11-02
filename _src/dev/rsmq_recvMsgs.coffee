qconf = require "./queue.json"

async = require "async"
RedisSMQ = require "rsmq"
rsmq = new RedisSMQ qconf.rsmq
tools = require "../lib/tools"


receive = (cb) ->
	rsmq.receiveMessage { qname: qconf.qname }, (err, resp) ->
		if err?
			console.log err
			cb(err)
			return

		if resp?.id?
			console.log "received:", resp
			cb(null, resp)
		else
			cb(null)
		return
	return


del = (id, cb) ->
	rsmq.deleteMessage { qname: qconf.qname, id: id }, (err, resp) ->
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


startReceiving = () ->
	receiveAfterTimeout = () ->
		timeout = rand(5, 100)
		console.log "next msg in #{timeout}ms"
		setTimeout((() ->
			receive (err, resp) ->
				return if err?
				if resp?.id?
					del resp.id, (err, success) ->
						return if err?
						console.log "id" if not success
						receiveAfterTimeout()
						return
				else receiveAfterTimeout()
				return
			return
		), timeout)
		return

	receiveAfterTimeout()
	return

startReceiving()
