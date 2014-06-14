http = require './http'
ServerHandler = {
	Meta: require './server/meta'
	Rest: require './server/rest'
}

class Server
	options: {
		rest: {
			port: 8765
		}
		meta: {
			port: 9876
		}
	}

	constructor: (options) ->
		@options[key] = val for key, val of options

		return if App.isRemote

		(new App.DB).migrate()

		http.createServer((new ServerHandler.Rest).handler).listen(@options.rest.port)
		http.createServer((new ServerHandler.Meta).handler).listen(@options.meta.port)

		console.log ""
		console.log "##################################################"
		console.log ""
		console.log "inspired-server"
		console.log ""
		console.log "REST Server: http://localhost:#{@options.rest.port}/"
		console.log "META Server: http://localhost:#{@options.meta.port}/"
		console.log ""
		console.log "##################################################"
		console.log ""

module.exports = Server