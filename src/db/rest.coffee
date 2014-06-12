http = require 'http'
Q = require 'q'

class AdapterRestAPI
	constructor: (@options = {}) ->
	migrate: (classes) ->
	query: (method, path, data) ->
		deferred = Q.defer()
		options = {
			host: @options.host || 'localhost'
			port: @options.port || 8765
			method: method
			path: path
		}
		request = http.request options, (response) ->
			result = ''
			response.on 'data', (chunk) -> result += chunk
			response.on 'end', ->
				if result isnt ""
					deferred.resolve JSON.parse result
				else
					deferred.resolve()
		request.on 'error', (e) ->
			deferred.reject e
		request.write(data) if data?
		request.end()
		return deferred.promise
	getOne: (name, uuid) ->
		@query 'GET', "/#{name}/#{uuid}.json"
	getAll: (name, condition) ->
		@query 'GET', "/#{name}.json"
			.then (result) ->
				(value for key, value of result._links)
	saveOne: (name, uuid, entity) ->
		if uuid?
			@query 'PUT', "/#{name}/#{uuid}.json", JSON.stringify entity
		else
			@query 'POST', "/#{name}.json", JSON.stringify entity
	deleteOne: (name, uuid) ->
		@query 'DELETE', "/#{name}/#{uuid}.json"

module.exports = AdapterRestAPI