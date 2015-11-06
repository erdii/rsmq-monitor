_ = require "lodash"
express = require "express"
tools = require "../lib/tools"

class RMAPIv1 extends require("../lib/base")
	model: require "../models/api_v1"

	constructor: () ->
		super
		return

	createRoutes: (baseroute, app) =>
		app.get(baseroute + "/:key", @getAllStats)
		app.get(baseroute + "/:key/count", @getCount)
		app.get(baseroute + "/:key/recv", @getReceived)
		app.get(baseroute + "/:key/sent", @getSent)
		return

	handleAnswer: (res, healthyStatusCode = 200) ->
		return (err, resp) ->
			if err?
				code = err.statusCode or 500
				res.status(code).send(err)
				return

			res.status(healthyStatusCode).send(resp)
			return

	getAllStats: (req, res) =>
		@model.getAllStats(req, @handleAnswer(res))
		return

	getCount: (req, res) =>
		@model.getCount(req, @handleAnswer(res))
		return

	getReceived: (req, res) =>
		@model.getReceived(req, @handleAnswer(res))
		return

	getSent: (req, res) =>
		@model.getSent(req, @handleAnswer(res))
		return

module.exports = new RMAPIv1()
