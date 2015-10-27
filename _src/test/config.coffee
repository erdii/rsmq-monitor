should = require "should"
config = require "../lib/config"

describe "load config", () ->
	cnf = config.get("rrdtool")
	console.log cnf
	(1).should.be.eql(1)
	return
