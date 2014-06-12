fs = require 'fs'
hal = require 'hal'
uuid = require 'node-uuid'
handlebars = require 'handlebars'

class Rest
	templates: {}
	constructor: ->
		# DB
		@db = new App.DB

		# Load templates
		@_loadTemplate(name) for name in ['html']

	_loadTemplate: (name) ->
		fs.readFile "#{__dirname}/../../templates/#{name}.hbs", 'utf8', (err, data) =>
			@templates[name] = handlebars.compile data

	handler: (request, response) =>
		# Router
		router = new App.Router request

		# Access logs
		response.on 'finish', () ->
			console.log request.connection.remoteAddress, response.statusCode, request.method, request.url

		# 400 Error Handling
		unless router.isValid() or router.isIndex()
			response.writeHead 400
			response.end()

		# CORS
		if request.headers.origin?
			response.setHeader 'Access-Control-Allow-Origin', request.headers.origin
			response.setHeader 'Access-Control-Allow-Credentials', 'true'
			response.setHeader 'Access-Control-Allow-Methods', 'HEAD,GET,PUT,POST,PATCH,LINK,UNLINK,DELETE'

		# Entity Class
		entityClass = @db.registry router.name
		relationClass = @db.registry router.rel

		# Relation
		if router.rel
			###
				@todo Fix SQL injection
			###
			relatedInstance = new relationClass
			relatedKey = (key for key, field of relatedInstance.fields() when field.references? and field.references() is router.name)[0]
			collection = @db.collection router.rel, "#{relatedKey} = '#{router.id}'"

			switch request.method
				when 'HEAD'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'GET'
					collection.load().then =>
						resource = new App.Hal.Resource collection, router
						switch router.format
							when 'json'
								response.writeHead 200, {'Content-Type': 'application/json'}
								response.end JSON.stringify resource.toJSON()
							when 'xml'
								response.writeHead 200, {'Content-Type': 'application/xml'}
								response.end resource.toXML()
							else
								response.writeHead 200, {'Content-Type': 'text/html'}
								response.end @templates.html resource.toJSON()
				when 'PUT'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'POST'
					request.readJSON()
						.then (data) =>
							instance = new relationClass data
							instance.uuid = uuid.v4()
							instance[relatedKey] = router.id
							instance.save()
								.then (result) =>
									resource = new App.Hal.Resource instance, router
									response.writeHead 303, 'See Other', {
										Location: resource._links.self.href
									}
									response.end()
								.catch (e) =>
									throw e
						.catch (e) =>
							console.log '[ERROR]', e
							response.writeHead 503, {'Content-Type': 'application/json'}
							response.write JSON.stringify e
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

		# Entity
		else if router.id
			switch request.method
				when 'HEAD'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'GET'
					instance = new entityClass
					instance.load(router.id).then =>
						resource = new App.Hal.Resource instance, router
						switch router.format
							when 'json'
								response.writeHead 200, {'Content-Type': 'application/json'}
								response.end JSON.stringify resource.toJSON()
							when 'xml'
								response.writeHead 200, {'Content-Type': 'application/xml'}
								response.end resource.toXML()
							else
								response.writeHead 200, {'Content-Type': 'text/html'}
								response.end @templates.html resource.toJSON()
				when 'PUT'
					request.readJSON().then (data) =>
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
					instance.load(router.id).then =>
						instance.delete()
							.then ->
								response.writeHead 200
								response.end()
							.catch (e) =>
								console.log '[ERROR]', e
								response.writeHead 503, {'Content-Type': 'application/json'}
								response.write JSON.stringify e
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
					collection.load().then =>
						resource = new App.Hal.Resource collection, router
						switch router.format
							when 'json'
								response.writeHead 200, {'Content-Type': 'application/json'}
								response.end JSON.stringify resource.toJSON()
							when 'xml'
								response.writeHead 200, {'Content-Type': 'application/xml'}
								response.end resource.toXML()
							else
								response.writeHead 200, {'Content-Type': 'text/html'}
								response.end @templates.html resource.toJSON()
				when 'PUT'
					response.writeHead 501, "Not Implemented"
					response.end()
				when 'POST'
					request.readJSON()
						.then (data) =>
							instance = new entityClass data
							instance.uuid = uuid.v4()
							instance.save()
								.then (result) =>
									resource = new App.Hal.Resource instance, router
									response.writeHead 303, 'See Other', {
										Location: resource._links.self.href
									}
									response.end()
								.catch (e) =>
									throw e
						.catch (e) =>
							console.log '[ERROR]', e
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

		# Index
		else
			resource = new App.Hal.Resource Object.keys(@db.registry()), router
			switch router.format
				when 'json'
					response.writeHead 200, {'Content-Type': 'application/json'}
					response.end JSON.stringify resource.toJSON()
				when 'xml'
					response.writeHead 200, {'Content-Type': 'application/xml'}
					response.end resource.toXML()
				else
					response.writeHead 200, {'Content-Type': 'text/html'}
					response.end @templates.html resource.toJSON()

module.exports = Rest