Field = require './field'
Q = require 'q'

class _Base
	@_fields: {}
	@_db

	constructor: (data) ->
		# DB
		@constructor._db = new App.DB unless @constructor._db?

		# Instantiate fields as static property
		unless @constructor._fields[@constructor.name]?
			@constructor._fields[@constructor.name] = {}
		for prop of @ when @[prop] instanceof Field._Base
			@constructor._fields[@constructor.name][prop] = @[prop]
			@[prop] = @constructor._fields[@constructor.name][prop].default()

		# Set key/values
		@_setProperties data

	_setProperties: (data) ->
		@[key] = val for key, val of data

	_tableName: ->
		@constructor.name.toLowerCase()

class Default extends _Base
	uuid: new Field.Uuid()

	load: (uuid) ->
		@constructor._db.adapter().getOne(@_tableName(), uuid)
			.then (result) =>
				@._setProperties result

	validate: ->
		fields = @constructor._fields[@constructor.name]
		errors = (column for column, field of fields when not field.isValid(@[column]))
		return {
			errors: errors
			isValid: !errors.length
		}
	save: ->
		deferred = Q.defer()

		validation = @validate()
		if validation.isValid is true
			@constructor._db.adapter().saveOne(@_tableName(), @uuid, @)
				.then (result) -> deferred.resolve result
		else
			deferred.reject validation

		return deferred.promise

	delete: ->
		@constructor._db.adapter().deleteOne(@_tableName(), @uuid)
			.then ->
				delete @

module.exports = {
	_Base: _Base
	Default: Default
}