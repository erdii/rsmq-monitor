_ = require "lodash"

errorTemplates =
	"EINVALIDRESPONSE": ["invalid response from `<%= from %>`: `<%= resp %>`", 500]
	"EMISSINGPROPERTY": ["missing property `<%= property %>` in `<%= identifier %>`", 500]
	"ENOTIMPLEMENTED": ["`<%= funcname %>` is not implemented yet", 500]
	"ETYPE": ["`<%= identifier %>` must be of type `<%= expected %>`", 500]

class RMErrors
	constructor: () ->
		@_errors = {}
		@_errors[key] = _.template(msg[0]) for key, msg of errorTemplates
		return

	create: (name, opts={}) =>
		err = new Error()
		err.name = name
		err.message = @_errors[name](opts) or "-"
		err.statusCode = errorTemplates[name][1] or 500
		return err

module.exports = new RMErrors()
