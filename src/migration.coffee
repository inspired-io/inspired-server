class Migration
	constructor: (@table, @entityClass) ->
		@db = new App.DB
		@instance = new @entityClass
		@fields = @entityClass._fields[@instance.constructor.name]

		fieldsInCode = (name for name of @fields)

		sql = "SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name='#{@table}'"
		@db.adapter().query sql, []
			.then (result) =>
				###
					Index the result set by column name.
					The input is numerically keyed but the
					output uses the column name as the key.
				###
				rows = result.rows.reduce (rows, row) ->
					rows[row.column_name] = row
					rows
				, {}

				fieldsInDB = Object.keys(rows)

				onlyInDB = (name for name in fieldsInDB when fieldsInCode.indexOf(name) < 0)
				onlyInCode = (name for name in fieldsInCode when fieldsInDB.indexOf(name) < 0)
				inBoth = (name for name in fieldsInCode when fieldsInDB.indexOf(name) >= 0)

				queries = []

				# DROP fields
				for column in onlyInDB
					queries.push "ALTER TABLE \"#{@table}\" DROP IF EXISTS \"#{column}\" CASCADE"

				# ADD fields
				for column in onlyInCode
					field = @fields[column]
					length = if field.length() then "(#{field.length()})" else ''
					queries.push "ALTER TABLE \"#{@table}\" ADD \"#{column}\" #{field.type()}#{length}"

				# ALTER fields
				for column in inBoth
					field = @fields[column]
					row = rows[column]
					sql = ""

					typeChange = (field.type() isnt row.udt_name)
					lengthChange = (field.length() isnt row.character_maximum_length)
					defaultChange = (field.default() isnt row.column_default)

					sqlLength = if field.length() then "(#{field.length()})" else ''

					sql += " TYPE #{field.type()}#{sqlLength}" if typeChange or lengthChange
					sql += " SET DEFAULT #{field.default()}" if defaultChange
					sql = "ALTER TABLE \"#{@table}\" ALTER \"#{column}\"" + sql if sql
					queries.push sql if sql

				###
					1. Make sure the table exists or create it
					2. Run all the queries to migrate the schema
				###
				@db.adapter().query "CREATE TABLE IF NOT EXISTS \"#{@table}\" ()", []
					.then (result) =>
						console.log queries if queries.length
						for sql in queries
							@db.adapter().query sql, []
								.then (result) ->

module.exports = Migration