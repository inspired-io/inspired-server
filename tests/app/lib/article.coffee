class Article extends App.Entity.Default
	title: new App.Field.String
	body: new App.Field.Text
	comments: new App.Field.HasMany {
		references: -> 'comments'
	}

module.exports = Article