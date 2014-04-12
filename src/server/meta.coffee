Q = require 'q'
fs = require 'fs'
url = require 'url'
browserify = require 'browserify'
coffee = require 'coffee-script'
through = require 'through'

class Meta
	bundles: {}
	bundleOptions: {
		'/bundle.js': {}
		'/bundle.min.js': {}
		'/bundle.dev.js': {debug: true}
		'/bundle.node.js': {
			insertGlobalVars: ['__filename','__dirname']
			options: {builtins: false, commondir: false}
		}
	}

	constructor: ->
		@db = new App.DB

	getBrowserify: (options = {}) ->
		bTransform = (_path) ->
			data = ''
			write = (buf) -> data += buf
			return through write, ->
				if _path.slice(-6) is 'coffee'
					@queue coffee.compile data
				else
					@queue data
				@queue null

		b = browserify options
		b.ignore 'coffee-script'
		b.ignore 'browserify'
		b.ignore 'through'
		b.ignore './server'
		b.add process.mainModule.filename
		b.transform bTransform
		return b

	loadBundle: (path) ->
		deferred = Q.defer()

		if @bundles[path]?
			deferred.resolve @bundles[path]
		else if @bundleOptions[path]?
			args = @bundleOptions[path]
			bundleString = ''
			@getBrowserify(args.options).bundle(args)
				.on 'data', (chunk) -> bundleString += chunk
				.on 'end', =>
					@bundles[path] = bundleString
					deferred.resolve bundleString
		else
			deferred.reject "Path does not exist"

		return deferred.promise

	handler: (request, response) =>
		url = url.parse request.url

		@loadBundle url.path
			.then (bundleString) ->
				response.writeHead 200, {'Content-Type': 'text/javascript'}
				response.write bundleString
				response.end()
			.catch (e) ->
				response.writeHead 404
				response.end()

module.exports = Meta