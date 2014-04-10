url = require 'url'

###
	The REGEXP will match the following URLs:
		/{name}
		/{name}.{format}
		/{name}/{id}
		/{name}/{id}.{format}

	The URL gets parsed into parts:
		#1: name
		#2: id OR `undefined`
		#3: format OR `undefined`
###

class Router
	format: 'html'

	constructor: (@request) ->
		@url = url.parse @request.url, true
		@info = /^\/([a-z0-9_]+)(?:(?:\/([^.]+))?(?:\.([a-z]+))?)?$/.exec @url.pathname

		console.log "[ROUTER - #{request.method}]", @info
		return unless @isValid()

		@name = @info[1]
		@id = @info[2]
		@format = @info[3]

	isValid: ->
		@info?

module.exports = Router
