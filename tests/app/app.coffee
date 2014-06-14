App = require('inspired-server').App

App.Entity.Article = require './lib/article.coffee'
App.Entity.Comment = require './lib/comment.coffee'
App.Entity.Profile = require './lib/profile.coffee'
App.Entity.User = require './lib/user.coffee'

db = new App.DB
db.dsn App.Config.get('dsn')
db.registry 'articles', App.Entity.Article
db.registry 'comments', App.Entity.Comment
db.registry 'profiles', App.Entity.Profile
db.registry 'users', App.Entity.User

new App.Server({
	rest: {port: App.Config.get('restPort')}
	meta: {port: App.Config.get('metaPort')}
})