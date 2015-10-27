module.exports = ( grunt ) ->
	grunt.initConfig
		pkg:   grunt.file.readJSON( 'package.json' )

		watch:
			gruntfile:
				files: ["Gruntfile.coffee"]
				options:
					reload: true

			app:
				files: [
					"_src/**/*.coffee"
				]
				tasks: [ "newer:coffee", "newer:copy" ]

		coffee:
			app:
				expand: true
				cwd: "_src"
				src: ["**/*.coffee"]
				dest: "app/"
				ext: ".js"

		copy:
			app:
				expand: true
				cwd: "_src"
				src: ["**/*.json"]
				dest: "app/"
				ext: ".json"

		clean:
			app:
				src: ["app/*"]

		mochacli:
			options:
				require: ["should"]
				reporter: "spec"
				bail: true
			config:
				src: ["app/test/config.js"]

	# Load npm modules
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-mocha-cli"
	grunt.loadNpmTasks "grunt-newer"


	grunt.registerTask "default", ["watch"]
	grunt.registerTask "bwatch", ["build", "watch"]
	grunt.registerTask "build", [ "clean", "coffee", "copy"]
	grunt.registerTask "mocha", ["mochacli"]
