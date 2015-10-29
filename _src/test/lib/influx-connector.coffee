now = () -> Math.floor(Date.now()/1000)

describe "devtesting", () ->
	@timeout(10000000)
	it "writePoints", (done) ->
		influx = require "../../lib/influx-connector"
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
	return
