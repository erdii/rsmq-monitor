class Bla
	constructor: (type) ->
		if type is 1
			@one()
		else
			@two()

	one: () ->
		console.log "one!"
		return

	two: () ->
		console.log "two!"
		return

new Bla(1)
new Bla(2)
