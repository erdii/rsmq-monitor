_ = require "lodash"

errorTemplates =
	"ETYPE": "`<%= identifier %>` must be of type `<%= expected %>`"
	"EMISSINGPROPERTY": "missing property `<%= property %>` in `<%= identifier %>`"

class RMErrors
	constructor: () ->
		@_errors = {}
		@_errors[key] = _.template(msg) for key, msg of errorTemplates
		return

	create: (name, opts={}) =>
		err = new Error()
		err.name = name
		err.message = @_errors[name](opts) or "-"
		return err

module.exports = new RMErrors()
