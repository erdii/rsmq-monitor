should = require "should"

describe "load corrupted config", () ->
	it "catching error", (done) ->
		should.throws (() ->
			require "../lib/config"
			return),
			((err) ->
				if err instanceof Error and /type/.test(err) and /config.queues/.test(err)
					done()
					return true
				return)
		return
	return
