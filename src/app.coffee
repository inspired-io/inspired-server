
global.App = App = {
	Helpers: require './helpers'
	Entity: require './entity'
	Field: require './field'
	Server: require './server'
	Router: require './router'
	DB: require './db'
	isRemote: process.browser? or process.mainModule.loaded
}

if App.isRemote
	App.DB.adapter new (require './db/rest')
else
	App.DB.adapter new (require './db/pg')

module.exports.App = App
