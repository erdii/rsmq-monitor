module.exports = ( grunt ) ->
	grunt.initConfig
		pkg:   grunt.file.readJSON( 'package.json' )

##########
		watch:
			gruntfile:
				files: ["Gruntfile.coffee"]
				options:
					reload: true

			app:
				files: [
					"_src/**/*.coffee"
				]
				tasks: [ "newer:coffeelint", "newer:coffee" ]

			jsons:
				files: [
					"_src/**/*.json"
				]
				tasks: [ "newer:copy" ]

###########
		coffee:
			app:
				expand: true
				cwd: "_src"
				src: ["**/*.coffee"]
				dest: "app/"
				ext: ".js"

###############
		coffeelint:
			app: ["_src/**/*.coffee"]
			options:
				configFile: "coffeelint.json"

#########
		copy:
			app:
				expand: true
				cwd: "_src"
				src: ["**/*.json"]
				dest: "app/"
				ext: ".json"

##########
		clean:
			app:
				src: ["app/*"]
			doc:
				src: ["doc/*"]

###########
		docker:
			app:
				src: [
					"_src/**/*"
					"README.md"
				]
				options:
					out: "doc/"

###############
		"gh-pages":
			src: ["**"]
			options:
				base: "doc"

############
		mochacli:
			options:
				require: ["should"]
				reporter: "spec"
				bail: true
			brokenconfig_type:
				src: ["app/test/lib/brokenconfig_type.js"]
				options:
					env:
						CONF: "./app/test/lib/configs/brokenconfig_type.json"
			brokenconfig_property:
				src: ["app/test/lib/brokenconfig_property.js"]
				options:
					env:
						CONF: "./app/test/lib/configs/brokenconfig_property.json"
			config:
				src: ["app/test/lib/config.js"]
				options:
					env:
						CONF: "./app/test/lib/configs/config.json"
			influx:
				src: ["app/test/lib/influx-connector.js"]
				options:
					env:
						CONF: "./app/test/lib/configs/config_influx.json"


###########
		rename:
			docIndex:
				files: [
					{
						src: ["doc/README.md.html"]
						dest: ["doc/index.html"]
					}
				]

	# Load npm modules
	grunt.loadNpmTasks "grunt-coffeelint"
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-rename"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-docker"
	grunt.loadNpmTasks "grunt-gh-pages"
	grunt.loadNpmTasks "grunt-mocha-cli"
	grunt.loadNpmTasks "grunt-newer"


	grunt.registerTask "default", ["watch"]
	grunt.registerTask "bwatch", ["build", "watch"]
	grunt.registerTask "build", [ "clean", "coffeelint", "coffee", "copy", "docker", "rename"]
	grunt.registerTask "test", ["mochacli"]
