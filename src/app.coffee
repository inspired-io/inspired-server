
global.App = App = {
	Collection: require './collection'
	Config: require './config'
	DB: require './db'
	Entity: require './entity'
	Field: require './field'
	Hal: require './hal'
	Helpers: require './helpers'
	Router: require './router'
	Server: require './server'

	isRemote: process.browser? or process.mainModule.loaded
}

if App.isRemote
	App.DB.adapter new (require './db/rest')
	App.Server = ->
else
	App.DB.adapter new (require './db/pg')

module.exports.App = App
