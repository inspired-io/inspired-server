http = require './http'
ServerHandler = {
	Meta: require './server/meta'
	Rest: require './server/rest'
}

class Server
	constructor: ->
		return if App.isRemote
		http.createServer((new ServerHandler.Rest).handler).listen(8765)
		http.createServer((new ServerHandler.Meta).handler).listen(9876)

module.exports = Server