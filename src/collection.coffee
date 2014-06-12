class Collection
	array: []
	constructor: (@name, @condition) ->
		# DB
		@constructor._db = new App.DB unless @constructor._db?

	toArray: -> @array

	load: ->
		entityClass = @constructor._db.registry @name
		@constructor._db.adapter().getAll(@name, @condition).then (rows) =>
			@array = (new entityClass(row) for row in rows)

module.exports = Collection