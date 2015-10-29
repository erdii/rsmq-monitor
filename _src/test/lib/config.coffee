should = require "should"
describe "load valid config", () ->
	it "validating processed config object", (done) ->
		expected =
			influx:
				host: "10.0.0.1"
				port: 1234
				database: "testdb"
				username: "user"
				password: "pass"
			queue_defaults:
				host: "10.0.0.2"
				port: 4321
				ns: "namespace"
				interval: 5
			queues: [
				{ key: "queue1", qname: "q1", host: "10.0.0.2", port: 4321, ns: "namespace", interval: 5 }
				{ key: "queue2", qname: "q2", host: "10.0.0.2", port: 4321, ns: "namespace", interval: 10 }
				{ key: "queue3", qname: "q3", host: "10.0.0.3", port: 6379, ns: "rsmq2", interval: 5 }
			]
		cnf = require "../../lib/config"
		should.deepEqual(cnf.get(), expected)
		done()
		return
	return
