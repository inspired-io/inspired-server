casper.test.begin 'Server tests', 5, (test) ->
	casper.start()

	data = {
		entity: null
		description: 'What a cool description'
	}

	###
		POST /todo
	###
	casper.then ->
		@open 'http://localhost:8765/todo', {
			method: 'POST'
			data: JSON.stringify {
				'description': data.description
			}
		}
		@then ->
			data.entity = JSON.parse @getPageContent()
			test.assertEquals data.entity.description, data.description, "Create Entity"

	###
		GET /todo/[UUID]
	###
	casper.then ->
		@open 'http://localhost:8765/todo/' + data.entity.uuid, {
			method: 'GET'
		}
		@then ->
			entity = JSON.parse @getPageContent()
			test.assertEquals entity, data.entity, "Fetch Entity"

	###
		GET /todo
	###
	casper.then ->
		@open 'http://localhost:8765/todo', {
			method: 'GET'
		}
		@then ->
			entities = JSON.parse @getPageContent()
			matches = (entity for entity in entities when entity.uuid is data.entity.uuid)
			test.assertEquals matches.length, 1, "Check Entity appears in List"

	###
		DELETE /todo/[UUID]
	###
	casper.then ->
		@open 'http://localhost:8765/todo/' + data.entity.uuid, {
			method: 'DELETE'
		}
		@then ->
			test.assert true, "Delete Entity"

	###
		GET /todo
	###
	casper.then ->
		@open 'http://localhost:8765/todo', {
			method: 'GET'
		}
		@then ->
			entities = JSON.parse @getPageContent()
			matches = (entity for entity in entities when entity.uuid is data.entity.uuid)
			test.assertEquals matches.length, 0, "Check Entity has been removed from List"

	casper.run ->
		test.done()