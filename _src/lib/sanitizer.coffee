class RMSanitizer
	sanitizerRules:
		"'" : "&apos;"
		'"' : "&quot;"

	sanitize: (toSanitize) =>
		# if toSanitize is undefined just return it so the validator can reject the field properly
		if not toSanitize? or not toSanitize.length
			return toSanitize
		return @replaceAllMulti((toSanitize + ""), @sanitizerRules)

	replaceAllMulti: (str, rules) =>
		for subStr, newSubStr of rules
			str = @replaceAll(str, subStr, newSubStr)
		return str

	replaceAll: (str, subStr, newSubStr, prevStr) =>
		if prevStr and str is prevStr
			return str
		prevStr = str.replace(subStr, newSubStr)
		return @replaceAll(prevStr, subStr, newSubStr, str)

module.exports = (new RMSanitizer()).sanitize
