url = require 'url'

###
	The REGEXP will match the following URLs:
		/{name}
		/{name}.{format}
		/{name}/{id}
		/{name}/{id}.{format}
		/{name}/{id}/{rel}
		/{name}/{id}/{rel}.{format}

	The URL gets parsed into parts:
		#1: name
		#2: id OR `undefined`
		#3: rel OR `undefined`
		#4: format OR `undefined`
###

class Router
	constructor: (@request) ->
		@url = url.parse @request.url, true
		@info = /^\/([a-z0-9_]+)(?:(?:\/([^.\/]+))?(?:\/([^.\/]+))?(?:\.([a-z]+))?)?$/.exec @url.pathname

		return unless @isValid()

		@name = @info[1]
		@id = @info[2]
		@rel = @info[3]
		@format = @info[4]

	isIndex: ->
		@url.pathname is '/'

	isValid: ->
		@info? and @info[0] not in [
			'/favicon.ico'
		]

module.exports = Router
