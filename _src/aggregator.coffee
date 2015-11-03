_ = require "lodash"
cluster = require "cluster"
config = require "./lib/config"
influxconn = require "./lib/influx-connector"
rsmqconn = require "./lib/rsmq-connector"
tools = require "./lib/tools"

class RMAggregator extends require("./lib/base")
	constructor: () ->
		super

		if cluster.isMaster
			@initMaster()
		else
			@initWorker()
		return

	initMaster: () =>
		@debug config.get()
		@debug "MASTER"

		@queues = config.get("queues")
		@workers = {}
		@timeouts = []

		cluster.on "fork", (worker) =>
			@timeouts[worker.id] = setTimeout((() ->
				console.log("something is wrong with #{worker.id}")
				return), 2000)
			return
		cluster.on "online", (worker) =>
			clearTimeout @timeouts[worker.id]
			return
		cluster.on "exit", (worker) =>
			clearTimeout @timeouts[worker.id]
			console.log "something is wrong with #{worker.id}"
			for _k, _v of @workers
				if _v.id is worker.id
					delete @workers[_k]
			@respawnWorkers()
			return

		@respawnWorkers()
		return

	respawnWorkers: () =>
		for key, queue of @queues
			@workers[key] = cluster.fork({QKEY: key}) unless @workers[key]?
		return

	initWorker: () =>
		@QKEY = process.env.QKEY
		@debug "WORKER for Key: #{@QKEY} created"
		@localconf = config.get("queues")?[@QKEY]
		@rsmq = new rsmqconn(@localconf)

		setTimeout((() =>
			@work()
			return), 500)

		# Debug: kill the worker after awhile so we see if it respawns
		# kill = () ->
		# 	process.exit(1)
		# 	return
		# setTimeout(kill, tools.rand(1000, 5000))
		return

	work: () =>
		@rsmq.getStats @localconf.qname, (err, resp) =>
			if err?
				@logErr err
				# maybe count errors and kill worker after x errors
				process.exit(1)

			@debug resp
			inner =
				time: tools.now()
				count: resp.msgs
				sent: resp.totalsent
				recv: resp.totalrecv
			data = {}
			data[@QKEY] = inner
			influxconn.writeStats data, (err, resp) =>
				if err?
					@logErr err
					process.exit(1)

				# TODO: stop working time and subtract
				setTimeout(@work, @localconf.interval * 1000)
				return
			return
		return

new RMAggregator()
