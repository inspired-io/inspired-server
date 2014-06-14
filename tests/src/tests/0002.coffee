casper.test.begin 'Test 0002 - OneToMany/ManyToOne', 8, (test) ->
	data = {
		article: null
		comment1: null
		comment2: null
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
			test.assertEquals data.article.body, data.body, "Create base entity"

	casper.then ->
		@inspired.post "/comments.json", {
			body: data.body
			article: data.article.uuid
		}
		@then ->
			data.comment1 = JSON.parse @getPageContent()
			test.assertEquals data.comment1.body, data.body, 'Create related entity and link via data'

	casper.then ->
		@inspired.post "/articles/#{data.article.uuid}/comments.json", {
			body: data.body
		}
		@then ->
			data.comment2 = JSON.parse @getPageContent()
			test.assertEquals data.comment2.body, data.body, 'Create related entity and link via URI'

	casper.then ->
		@inspired.get "/articles/#{data.article.uuid}/comments.json"
		@then ->
			matches1 = @inspired.findInList(data.comment1.uuid, JSON.parse @getPageContent())
			matches2 = @inspired.findInList(data.comment2.uuid, JSON.parse @getPageContent())
			test.assertEquals matches1.length, 1, 'Related1 In List'
			test.assertEquals matches2.length, 1, 'Related2 In List'

	casper.then ->
		@inspired.delete "/articles/#{data.article.uuid}/comments.json"
		@then (response) ->
			test.assertEquals response.status, 200, "Delete All Related"

	casper.then ->
		@inspired.delete "/articles/#{data.article.uuid}.json"
		@then (response) ->
			test.assertEquals response.status, 200, "Delete Base"

	casper.then ->
		data.date.end = new Date()
		total = data.date.end - data.date.start
		test.assert (total < 500), "Speed < 500ms (#{total})"

	casper.run ->
		test.done()