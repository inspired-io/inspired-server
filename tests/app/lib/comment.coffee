class Comment extends App.Entity.Default
	body: new App.Field.Text
	article: new App.Field.HasOne {
		unique: -> false
		references: -> 'articles'
	}

module.exports = Comment