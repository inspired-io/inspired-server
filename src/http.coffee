http = require 'http'
Q = require 'q'

if http? and http.IncomingMessage?
	http.IncomingMessage.prototype.readData = ->
		deferred = Q.defer()
		data = new String
		@on 'data', (chunk) -> data += chunk
		@on 'end', -> deferred.resolve data
		@on 'error', (e) -> deferred.reject e
		return deferred.promise

	http.IncomingMessage.prototype.readJSON = ->
		@readData()
			.then (data) -> JSON.parse(data)
			.catch (e) -> throw String(e)

module.exports = http