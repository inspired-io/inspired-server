App = require('inspired-server').App

App.Entity.Article = require './lib/article.coffee'
App.Entity.Comment = require './lib/comment.coffee'

db = new App.DB
db.dsn App.Config.get('dsn')
db.registry 'articles', App.Entity.Article
db.registry 'comments', App.Entity.Comment

new App.Server({
	rest: {port: App.Config.get('restPort')}
	meta: {port: App.Config.get('metaPort')}
})