# ic = require "../lib/influx-connector"
#
# # ic.maintainContinuousQueries (err) ->
# # 	console.dir err if err?
# # 	return
#
# # opts =
# # 	fields: "mean(count) as count, mean(sent) as sent, mean(recv) as recv"
# # 	where: "time > now() - 10m"
# # 	group: "time(1m)"
# #
# # ic.getStats "queue1", opts , (err, resp) ->
# # 	console.log resp
# # 	return
#
#
# opts2 =
# 	where: "time > now() - 10m"
#
# ic.getStats "queue1", opts2 , (err, resp) ->
# 	console.log resp
# 	return
extend = require "extend"

now = Date.now()
opts =
	start: "#{now - 6 * 60000}ms"
	end: "#{now - 5 * 60000}ms"
	group: "1s"

def =
	start: "now() - 60m"
	group: "1m"

console.dir extend({}, def, opts)


apimodel = require "../models/api_v1"

apimodel.getAllStats "queue1", (err, resp) ->
	console.log err, resp

	console.log "================"
	console.log "================"
	console.log "================"

	now = Date.now()
	opts =
		start: "#{now - 6 * 60000}ms"
		end: "#{now - 5 * 60000}ms"
		group: "1s"
	apimodel.getAllStats "queue1", opts, (err, resp) ->
		console.log err, resp
		return
	return
