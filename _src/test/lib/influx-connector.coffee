should = require "should"

now = () -> Math.floor(Date.now()/1000)

describe "Testing Influx-connector module", () ->
	@timeout(10000000)
	influx = require "../../lib/influx-connector"
	it "writeStats", (done) ->
		data =
			test_queue1: [
				{ time: now() - 15, count: 150, sent: 120000, recv: 119850 }
				{ time: now() - 10, count: 100, sent: 120000, recv: 119900 }
				{ time: now() - 5, count: 50, sent: 120000, recv: 119950 }
				{ time: now(), count: 0, sent: 120000, recv: 120000 }
			]
			test_queue2: { time: now(), count: 2, sent: 12, recv: 10 }

		influx.writeStats data, (err) ->
			console.log err if err?
			should.not.exist(err)
			done()
			return


	it "getStats", (done) ->
		influx.getStats "test_queue1", "all", { wildcard: true }, (err, resp) ->
			if not err?
				if resp?
					resp.length.should.be.exactly(4)
					done()
		return


	it "dropStats", (done) ->
		influx.dropStats "test_queue1", (err) ->
			if not err?
				influx.dropStats "test_queue2", (err) ->
					if not err?
						done()
					return
			return
		return
	return
