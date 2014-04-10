uuid = require 'node-uuid'

class Rest
	constructor: ->
		@db = new App.DB
	handler: (request, response) =>
		# Router
		router = new App.Router request

		# 400 Error Handling
		unless router.isValid()
			console.warn '400', router.url
			response.writeHead 400
			response.end()

		# CORS
		if request.headers.origin?
			response.setHeader 'Access-Control-Allow-Origin', request.headers.origin
			response.setHeader 'Access-Control-Allow-Credentials', 'true'
			response.setHeader 'Access-Control-Allow-Methods', 'HEAD,GET,PUT,POST,PATCH,LINK,UNLINK,DELETE'

		# Entity Class
		entityClass = @db.registry router.name
		console.log entityClass, 'EC', @db.constructor._registry

		# Entity
		if router.id
			switch request.method
				when 'HEAD'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'GET'
					instance = new entityClass
					instance.load(router.id).then ->
						response.writeHead 200, {'Content-Type': 'application/json'}
						response.end JSON.stringify instance
				when 'PUT'
					request.readJSON().then (data) ->
						instance = new entityClass data
						instance.save().then ->
							response.writeHead 200
							response.end()
				when 'POST'
					response.writeHead 405, 'Method Not Allowed'
					response.end()
				when 'PATCH'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'LINK'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'UNLINK'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'DELETE'
					instance = new entityClass
					instance.load(router.id).then ->
						instance.delete().then ->
							response.writeHead 200
							response.end()
				when 'OPTIONS'
					response.writeHead 200, {
						Allow: 'HEAD, GET, PUT, PATCH, LINK, UNLINK, DELETE'
					}
					response.end()
				else
					response.writeHead 405, 'Method Not Allowed', {
						Allow: 'HEAD, GET, PUT, PATCH, LINK, UNLINK, DELETE'
					}
					response.end()

		# Collection
		else if router.name
			collection = @db.collection router.name
			switch request.method
				when 'HEAD'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'GET'
					collection.load().then ->
						response.writeHead 200, {'Content-Type': 'application/json'}
						response.end JSON.stringify collection.toArray()
				when 'PUT'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'POST'
					request.readJSON()
						.then (data) ->
							instance = new entityClass data
							console.log 'HERE 2'
							instance.uuid = uuid.v4()
							console.log 'HERE 3'
							instance.save().then (result) ->
								console.log 'HERE 4'
								response.writeHead 303, 'See Other', {
									Location: '/' + router.name + '/' + instance.uuid
								}
								response.end()
						.catch (e) ->
							response.writeHead 503, {'Content-Type': 'application/json'}
							response.write JSON.stringify e
							response.end()
				when 'PATCH'
					response.writeHead 405, 'Method Not Allowed'
					response.end()
				when 'LINK'
					response.writeHead 405, 'Method Not Allowed'
					response.end()
				when 'UNLINK'
					response.writeHead 405, 'Method Not Allowed'
					response.end()
				when 'DELETE'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'OPTIONS'
					response.writeHead 200, {
						Allow: 'HEAD, GET, PUT, POST, DELETE'
					}
					response.end()
				else
					response.writeHead 405, {
						Allow: 'HEAD, GET, PUT, POST, DELETE'
					}
					response.end()

module.exports = Rest