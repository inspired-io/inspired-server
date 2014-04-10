class DB
	@adapter: (adapter) ->
		(new @).adapter(adapter)
	dsn: (dsn) ->
		@constructor._dsn = dsn if dsn?
		return @constructor._dsn
	adapter: (adapter) ->
		@constructor._adapter = adapter if adapter?
		return @constructor._adapter
	registry: (name, entityClass) ->
		@constructor._registry = {} unless @constructor._registry?
		return @constructor._registry if not name?
		return @constructor._registry[name] if not entityClass?
		@constructor._registry[name] = entityClass
		@adapter().migration name, entityClass
		return entityClass
	collection: (name) ->
		return new Collection @, name

class Collection
	array: []
	constructor: (@db, @name) ->
	toArray: -> @array
	load: ->
		@db.adapter().query("SELECT uuid FROM #{@name}").then (result) =>
			@array = result.rows

module.exports = DB