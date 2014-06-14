pg = require 'pg'
Q = require 'q'
Migration = require '../migration'

class AdapterPostgreSQL
	constructor: ->
		@db = new App.DB
	migrate: (classes) ->
		new Migration classes
	query: (query, params) ->
		console.log '[QUERY]', query, params
		deferred = Q.defer()
		pg.connect @db.dsn(), (err, client, done) ->
			if err
				done()
				deferred.reject err
				return console.error 'error fetching client from pool', err
			client.query query, params, (err, result) ->
				done()
				if err
					deferred.reject err
					# return console.error 'error running query', query, err
				else
					deferred.resolve result
		return deferred.promise
	getOne: (name, uuid) ->
		@query "SELECT * FROM #{name} WHERE \"uuid\" = $1", [uuid]
			.then (result) ->
				result.rows[0]
	getAll: (name, condition) ->
		sql = "SELECT * FROM #{name}"
		sql += " WHERE #{condition}" if condition
		@query sql
			.then (result) ->
				result.rows
	countAll: (name, condition) ->
		sql = "SELECT COUNT(\"uuid\") FROM #{name}"
		sql += " WHERE #{condition}" if condition
		@query sql
			.then (result) ->
				Number(result.rows[0].count)
	saveOne: (name, uuid, entity) ->
		@query "SELECT \"uuid\" FROM #{name} WHERE \"uuid\" = $1", [uuid]
			.then (result) =>
				fields = entity.fields()
				columns = (column for column, field of fields when not field.multiple())
				values = (entity[column] for column in columns)
				params = ('$' + ++i for val, i in values)

				if result.rows.length
					sql = "UPDATE #{name} SET (#{columns}) = (#{params}) WHERE \"uuid\" = '#{uuid}'"
				else
					sql = "INSERT INTO #{name} (#{columns}) VALUES (#{params})"

				@query sql, values
	deleteOne: (name, uuid) ->
		@query "DELETE FROM #{name} WHERE \"uuid\" = $1", [uuid]
	deleteAll: (name, condition) ->
		sql = "DELETE FROM #{name}"
		sql += " WHERE #{condition}" if condition
		@query sql

module.exports = AdapterPostgreSQL