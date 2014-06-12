casper.test.begin 'Server tests', 5, (test) ->
	casper.start()

	data = {
		entity: null
		description: 'What a cool description'
	}

	###
		POST /todos
	###
	casper.then ->
		@open 'http://localhost:8765/todos.json', {
			method: 'POST'
			data: JSON.stringify {
				'description': data.description
			}
		}
		@then ->
			data.entity = JSON.parse @getPageContent()
			test.assertEquals data.entity.description, data.description, "Create Entity"

	###
		GET /todos/[UUID]
	###
	casper.then ->
		@open "http://localhost:8765/todos/#{data.entity.uuid}.json", {
			method: 'GET'
		}
		@then ->
			entity = JSON.parse @getPageContent()
			test.assertEquals entity, data.entity, "Fetch Entity"

	###
		GET /todos
	###
	casper.then ->
		@open 'http://localhost:8765/todos.json', {
			method: 'GET'
		}
		@then ->
			list = JSON.parse @getPageContent()
			matches = (key for key, values of list._links when key is data.entity.uuid)
			test.assertEquals matches.length, 1, "Check Entity appears in List"

	###
		DELETE /todos/[UUID]
	###
	casper.then ->
		@open "http://localhost:8765/todos/#{data.entity.uuid}.json", {
			method: 'DELETE'
		}
		@then ->
			test.assert true, "Delete Entity"

	###
		GET /todos
	###
	casper.then ->
		@open 'http://localhost:8765/todos.json', {
			method: 'GET'
		}
		@then ->
			entities = JSON.parse @getPageContent()
			matches = (entity for entity in entities when entity.uuid is data.entity.uuid)
			test.assertEquals matches.length, 0, "Check Entity has been removed from List"

	casper.run ->
		test.done()