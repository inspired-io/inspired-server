pg = require 'pg'
Q = require 'q'
Migration = require '../migration'

class AdapterPostgreSQL
	constructor: ->
		@db = new App.DB
	migration: (name, entityClass) ->
		new Migration name, entityClass
	query: (query, params) ->
		deferred = Q.defer()
		pg.connect @db.dsn(), (err, client, done) ->
			if err
				done()
				deferred.reject new Error err
				return console.error 'error fetching client from pool', err
			client.query query, params, (err, result) ->
				done()
				if err
					deferred.reject new Error err
					return console.error 'error running query', query, err
				else
					deferred.resolve result
		return deferred.promise
	getOne: (name, uuid) ->
		@query "SELECT * FROM #{name} WHERE \"uuid\" = $1", [uuid]
			.then (result) ->
				result.rows[0]
	getAll: (name) ->
		@query "SELECT * FROM #{name}"
	saveOne: (name, uuid, entity) ->
		@query "SELECT \"uuid\" FROM #{name} WHERE \"uuid\" = $1", [uuid]
			.then (result) =>
				fields = entity.constructor._fields[entity.constructor.name]
				columns = (column for column of fields)
				values = (entity[column] for column of fields)
				params = ('$' + ++i for val, i in values)

				if result.rows.length
					sql = "UPDATE #{name} SET (#{columns}) = (#{params}) WHERE \"uuid\" = '#{uuid}'"
				else
					sql = "INSERT INTO #{name} (#{columns}) VALUES (#{params})"

				@query sql, values
	deleteOne: (name, uuid) ->
		@query "DELETE FROM #{name} WHERE \"uuid\" = $1", [uuid]

module.exports = AdapterPostgreSQL