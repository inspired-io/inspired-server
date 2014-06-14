class Config
	constructor: () ->
		@program = require 'commander'
		@program
			.option('-D, --dsn <dsn>', 'Set DSN')
			.option('-R, --rest-port <port>', 'Set REST port')
			.option('-M, --meta-port <port>', 'Set META port')
			.parse(process.argv);

	get: (key) ->
		@program[key]

module.exports = new Config