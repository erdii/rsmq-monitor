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



	####################
	# MASTER FUNCTIONS #
	####################
	initMaster: () =>
		@debug config.get()
		@debug "MASTER"
		@spawnWorkers()
		# influxconn.maintainContinuousQueries (err) =>
		# 	if err?
		# 		@logErr err
		# 		throw err
		#
		# 	@spawnWorkers()
		# 	return
		return

	spawnWorkers: () =>
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
			@workers[key] = cluster.fork({QKEY: key}) unless @workers[key]? and not @workers[key].isDead()
		return



	####################
	# WORKER FUNCTIONS #
	####################

	initWorker: () =>
		@QKEY = process.env.QKEY
		@debug "WORKER for Key: #{@QKEY} created"
		@localconf = config.get("queues")?[@QKEY]
		@rsmq = new rsmqconn(@localconf)
		@work(true)
		return

	work: (firstrun = false) =>
		starttime = Date.now()
		@debug "get stats (#{@localconf.qname}) from rsmq"
		@rsmq.getStats @localconf.qname, (err, resp) =>
			if err?
				@logErr err
				@nextIteration(starttime)
				return

			if firstrun
				@lastsent = resp.totalsent
				@lastrecv = resp.totalrecv
				@nextIteration(starttime)
				return

			payload =
				time: tools.now()
				count: resp.msgs
				sent: resp.totalsent - @lastsent
				recv: resp.totalrecv - @lastrecv

			@lastsent = resp.totalsent
			@lastrecv = resp.totalrecv

			data = {}
			data[@QKEY] = payload
			@debug "write stats to influx..."
			influxconn.writeStats data, (err) =>
				if err?
					@logErr err
					@nextIteration(starttime)
					return

				@debug "success!"
				@nextIteration(starttime)
				return
			return
		return

	nextIteration: (starttime) =>
		setTimeout @work, (@localconf.interval * 1000) - (Date.now() - starttime)
		return

# Run the App!
new RMAggregator()
