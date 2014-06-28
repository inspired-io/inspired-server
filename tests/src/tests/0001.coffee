casper.test.begin 'Test 0001 - Single Entity', 5, (test) ->
	data = {
		article: null
		body: 'What a cool description'
		date: {
			start: null
			end: null
		}
	}

	casper.start()

	data.date.start = new Date()

	casper.then ->
		@inspired.post "/articles.json", {
			body: data.body
		}
		@then ->
			data.article = JSON.parse @getPageContent()
			test.assertEquals data.article.body, data.body, "Create"

	casper.then ->
		@inspired.get "/articles/#{data.article.uuid}.json"
		@then ->
			entity = JSON.parse @getPageContent()
			test.assertEquals entity, data.article, "Fetch"

	casper.then ->
		@inspired.get "/articles.json"
		@then ->
			matches = @inspired.findInList(data.article.uuid, JSON.parse @getPageContent())
			test.assertEquals matches.length, 1, "In List"

	casper.then ->
		@inspired.delete "/articles/#{data.article.uuid}.json"
		@then (response) ->
			test.assertEquals response.status, 200, "Delete"

	casper.then ->
		@inspired.get "/articles.json"
		@then ->
			matches = @inspired.findInList(data.article.uuid, JSON.parse @getPageContent())
			test.assertEquals matches.length, 0, "Not In List"

	casper.run ->
		test.done()