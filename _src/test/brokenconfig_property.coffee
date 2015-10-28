should = require "should"

describe "load corrupted config", () ->
	it "catching error", (done) ->
		should.throws (() ->
			require "../lib/config"
			return),
			((err) ->
				if err instanceof Error and /property/.test(err) and /key/.test(err)
					done()
					return true
				return)
		return
	return
