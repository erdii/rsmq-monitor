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
				tasks: [ "newer:coffee" ]

		coffee:
			app:
				expand: true
				cwd: "_src"
				src: ["**/*.coffee"]
				dest: 'app/'
				ext: ".js"

		clean:
			app:
				src: ["app/*"]

	# Load npm modules
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-newer"


	grunt.registerTask "default", ["watch"]
	grunt.registerTask "bwatch", ["build", "watch"]
	grunt.registerTask "build", [ "clean:app", "coffee:app"]
