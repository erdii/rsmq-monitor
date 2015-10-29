now = () -> Math.floor(Date.now()/1000)

describe "devtesting", () ->
	@timeout(10000000)
	influx = require "../../lib/influx-connector"
	it "writeStats", (done) ->
		data =
			queue1: [
				{ time: now() - 15, count: 150, sent: 120000, recv: 119850 }
				{ time: now() - 10, count: 100, sent: 120000, recv: 119900 }
				{ time: now() - 5, count: 50, sent: 120000, recv: 119950 }
				{ time: now(), count: 0, sent: 120000, recv: 120000 }
			]
			queue2: { time: now(), count: 2, sent: 12, recv: 10 }

		influx.writeStats data, () ->
			done()
			return

	it "dropStats", (done) ->
		influx.dropStats "queue1", (err) ->
			if not err?
				influx.dropStats "queue2", (err) ->
					if not err?
						done()
					return
			return
		return
	return
