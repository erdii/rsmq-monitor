sanitizer_rgExp = /['|"]/g

module.exports = tools =
	sanitize: (inp) -> inp.replace(sanitizer_rgExp, "\\$&")
	now: () -> Math.floor(Date.now()/1000)
	rand: (min, max) -> Math.floor(Math.random() * (max-min)) + min
