http = require './http'
ServerHandler = {
	Meta: require './server/meta'
	Rest: require './server/rest'
}

class Server
	constructor: () ->
		return if App.isRemote
		(new App.DB).migrate()
		http.createServer((new ServerHandler.Rest).handler).listen(8765)
		http.createServer((new ServerHandler.Meta).handler).listen(9876)

		console.log ''
		console.log '##################################################'
		console.log ''
		console.log 'inspired-server'
		console.log ''
		console.log 'Point your browser here: http://localhost:8765/'
		console.log ''
		console.log '##################################################'
		console.log ''

module.exports = Server