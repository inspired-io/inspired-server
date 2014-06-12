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
		return entityClass
	migrate: ->
		@adapter().migrate @constructor._registry
	collection: (name, condition) ->
		return new App.Collection name, condition

module.exports = DB