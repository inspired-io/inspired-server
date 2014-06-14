class Collection
	length: null
	array: []

	constructor: (@name, @condition) ->
		# DB
		@constructor._db = new App.DB unless @constructor._db?

	toLength: -> @length

	toArray: -> @array

	load: ->
		entityClass = @constructor._db.registry @name
		@constructor._db.adapter().getAll(@name, @condition).then (rows) =>
			@array = (new entityClass(row) for row in rows)
			@length = @array.length

	count: ->
		@constructor._db.adapter().countAll(@name, @condition).then (length) =>
			@length = length

	delete: ->
		@constructor._db.adapter().deleteAll(@name, @condition).then () =>
			@array = []
			@length = 0

module.exports = Collection