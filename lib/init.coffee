{CompositeDisposable} = require 'atom'


module.exports =
	config:
		executablePath:
			type: 'string'
			title: 'Kotlin compiler executable'
			default: 'kotlinc'
		classpath:
			type: 'string'
			title: 'Extra classpath to kotlinc'
			default: ''
		compilerOutputDir:
			type: 'string'
			title: 'Compiler output directory'
			default: 'bin'
		commandTimeout:
			type: 'number'
			title: 'Number of seconds to wait for compilation completion'
			default: 30

	activate: ->
		require('atom-package-deps').install()
		@subscriptions = new CompositeDisposable

		@subscriptions.add atom.config.observe 'linter-kotlin.executablePath',
			(newExecutablePath) => @executablePath = newExecutablePath

		@subscriptions.add atom.config.observe 'linter-kotlin.classpath',
			(newClasspath) => @executablePath = newClasspath

		@subscriptions.add atom.config.observe 'linter-kotlin.compilerOutputDir',
			(newCoutDir) => @compilerOutputDir = newCoutDir

		@subscriptions.add atom.config.observe 'linter-kotlin.commandTimeout',
			(newCommandTimeout) => @commandTimeout = newCommandTimeout

	deactivate: ->
		@subscriptions.dispose()

	provideLinter: ->
		LinterKotlin = require('./linter-kotlin')
		@provider = new LinterKotlin()
		return {
			name: 'Kotlin'
			grammarScopes: ['source.kotlin']
			scope: 'project'
			lintOnFly: false
			lintsOnChange: false
			lint: @provider.lint
		}
