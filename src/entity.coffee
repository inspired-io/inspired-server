Field = require './field'
hal = require 'hal'
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
		unless @constructor._tableName?
			@constructor._tableName = (name for name, entityClass of @constructor._db.registry() when entityClass is @constructor)

		@constructor._tableName

class Default extends _Base
	uuid: new Field.Uuid()

	fields: ->
		@constructor._fields[@constructor.name]

	load: (uuid) ->
		@constructor._db.adapter().getOne(@_tableName(), uuid)
			.then (result) =>
				@._setProperties result

	validate: ->
		errors = (column for column, field of @fields() when not field.isValid(@[column]))
		{
			errors: errors
			isValid: !errors.length
		}

	save: ->
		deferred = Q.defer()

		validation = @validate()
		if validation.isValid is true
			@constructor._db.adapter().saveOne(@_tableName(), @uuid, @)
				.then (result) =>
					@uuid = result.uuid if result.uuid
					deferred.resolve result
				.catch (e) =>
					deferred.reject e
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