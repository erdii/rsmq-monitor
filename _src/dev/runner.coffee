ic = require "../lib/influx-connector"

# ic.maintainContinuousQueries (err) ->
# 	console.dir err if err?
# 	return

# opts =
# 	fields: "mean(count) as count, mean(sent) as sent, mean(recv) as recv"
# 	where: "time > now() - 10m"
# 	group: "time(1m)"
#
# ic.getStats "queue1", opts , (err, resp) ->
# 	console.log resp
# 	return


opts2 =
	where: "time > now() - 10m"

ic.getStats "queue1", opts2 , (err, resp) ->
	console.log resp
	return
