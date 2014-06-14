Q = require 'q'

class Migration
	constructor: (@classes) ->
		@db = new App.DB
		@queries = {
			tables: []
			dropConstraints: []
			dropFields: []
			fields: []
			uniques: []
			constraints: []
		}

		promises = [];
		for table, entityClass of @classes
			promises.push @prepareTable(table, entityClass)

		Q.all(promises)
			.then =>
				@runQueries()
			.catch (e) ->
				console.log '[ERROR]', e

	runQuery: (sql) ->
		console.log '[MIGRATION]', sql
		@db.adapter().query sql, []

	handleError: (sql, e) ->
		switch e.code
			when '42P07' then #nothing
			when '42710' then #nothing
			else console.log '[ERROR]', sql, e

	runQueries: ->
		deferred = Q.defer()
		deferred.resolve()

		for table, queries of @queries
			for sql in queries when sql? and sql isnt ''
				deferred.promise
					.then @runQuery.bind(@, sql)
					.catch @handleError.bind(@, sql)

	prepareTable: (table, entityClass) ->
		sql = "SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name='#{table}'"
		@db.adapter().query(sql, []).then @parseTable.bind(@, table, entityClass)

	parseTable: (table, entityClass, result) ->
		instance = new entityClass
		fields = instance.fields()

		data = {
			fields: {
				inCode: {}, inDB: {}, onlyInCode: {}, onlyInDB: {}, inBoth: {}
			}
			constraints: {
				inCode: {}, inDB: {}, onlyInCode: {}, onlyInDB: {}, inBoth: {}
			}
		}

		for name, field of fields
			data.fields.inCode[name] = field
			data.constraints.inCode[name] = field if field.isForeignKey()

		###
			Index the result set by column name.
			The input is numerically keyed but the
			output uses the column name as the key.
		###
		data.fields.inDB = result.rows.reduce (rows, row) ->
			rows[row.column_name] = row
			rows
		, {}

		###
			@todo Refactor
		###
		for name, row of data.fields.inDB when not data.fields.inCode[name]?
			data.fields.onlyInDB[name] = row
		for name, field of data.fields.inCode when not data.fields.inDB[name]?
			data.fields.onlyInCode[name] = field
		for name, field of data.fields.inCode when data.fields.inDB[name]?
			data.fields.inBoth[name] = field
		for name, row of data.constraints.inDB when not data.constraints.inCode[name]?
			data.constraints.onlyInDB[name] = row
		for name, field of data.constraints.inCode when not data.constraints.inDB[name]?
			data.constraints.onlyInCode[name] = field

		# Make sure the table exists or create it
		@queries.tables.push "CREATE TABLE IF NOT EXISTS \"#{table}\" ()"

		# DROP constraints
		for column, row of data.constraints.onlyInDB
			@queries.dropConstraints.push "ALTER TABLE \"#{table}\" DROP CONSTRAINT #{table}_#{column}_unique"
			@queries.dropConstraints.push "ALTER TABLE \"#{table}\" DROP CONSTRAINT #{table}_#{column}_fk"

		# DROP fields
		for column, row of data.fields.onlyInDB
			@queries.dropFields.push "ALTER TABLE \"#{table}\" DROP IF EXISTS \"#{column}\" CASCADE"

		# ADD fields
		for column, field of data.fields.onlyInCode
			if field.isForeignKey() and field.multiple()
				# if field.unique() # OneToMany
				# else # ManyToMany
				###
					@todo Handle ManyToMany
				###
			else
				@fieldHelper table, column, field

		# ALTER fields
		for column, field of data.fields.inBoth
			@fieldHelper table, column, field, data.fields.inDB[column]

		# ADD constraints
		for column, field of data.constraints.onlyInCode
			if field.multiple()
				# if field.unique() # OneToMany
				# else # ManyToMany
				###
					@todo Handle ManyToMany
				###
			else
				@fieldUniqueHelper table, column if field.unique() # OneToOne
				constraintName = "#{table}_#{column}_fk"
				@queries.constraints.push "ALTER TABLE \"#{table}\" ADD CONSTRAINT #{constraintName} FOREIGN KEY (\"#{column}\") REFERENCES \"#{field.references()}\" (\"uuid\")"

	fieldHelper: (table, column, field, row) ->
		sql = ''
		sqlLength = if field.length() then "(#{field.length()})" else ''

		if row?
			typeChange = (field.type() isnt row.udt_name)
			lengthChange = (field.length() isnt row.character_maximum_length)
			defaultChange = (field.default() isnt row.column_default)

			sql += " TYPE #{field.type()}#{sqlLength}" if typeChange or lengthChange
			sql += " SET DEFAULT #{field.default()}" if defaultChange
		else
			sql += " #{field.type()}#{sqlLength}"
			sql += " DEFAULT #{field.default()}"

		operation = if row? then "ALTER" else "ADD"
		sql = "ALTER TABLE \"#{table}\" #{operation} \"#{column}\"" + sql if sql

		@queries.fields.push sql if sql

		if field.unique()
			@fieldUniqueHelper table, column

	fieldUniqueHelper: (table, column) ->
		constraintName = "#{table}_#{column}_unique"
		@queries.uniques.push "ALTER TABLE \"#{table}\" ADD CONSTRAINT #{constraintName} UNIQUE (\"#{column}\")"

module.exports = Migration