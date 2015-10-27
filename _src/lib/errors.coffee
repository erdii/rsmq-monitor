class RMErrors
	create: ( name, opts={} )->

		_err = new Error()
		_err.name = name
		_err.message = @ERRORS[name] or "-"
		return _err
	ERRORS:
		"ETYPE": "config.queues must be an array"
module.exports = new RMErrors()
