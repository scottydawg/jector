module.exports = (grunt) ->

  grunt.initConfig

    clean:
      build: ['.tmp']

    watch:
      coffee:
        files: '**/*.coffee'
        tasks: ['compile']
      test:
        files: '.tmp/**/*.js'
        tasks: ['test']

    coffee:
      jector:
        options:
          join: true
        files:
          'dist/jector.js': ['src/**/*.coffee']

      unitTest:
        options:
          bare: true
        expand: true
        src: ['spec/**/*.spec.coffee']
        dest: '.tmp'
        ext: '.spec.js'

    jasmine_node:
      projectRoot: './.tmp',

  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-jasmine-node')
  #grunt.loadNpmTasks('grunt-contrib-copy')
  #grunt.loadNpmTasks('grunt-markdown')

  grunt.registerTask('test', ['jasmine_node'])
  grunt.registerTask('compile', ['coffee'])
  grunt.registerTask('build', ['clean', 'compile', 'test'])
  grunt.registerTask('default', ['clean', 'compile', 'watch'])
