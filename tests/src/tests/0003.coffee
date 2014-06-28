casper.test.begin 'Test 0003 - Peformance & Count', 4, (test) ->
	data = {
		article: null
		body: 'What a cool description'
		number: 50
		date: {
			start: null
			end: null
		}
	}

	casper.start()

	casper.then ->
		@inspired.post "/articles.json", {
			body: data.body
		}
		@then ->
			data.article = JSON.parse @getPageContent()
			test.assertEquals data.article.body, data.body, "Create base entity"

	casper.then ->
		for i in [1..data.number]
			@inspired.post "/articles/#{data.article.uuid}/comments.json", {
				body: data.body
			}
		@inspired.head "/articles/#{data.article.uuid}/comments.json"
		@then (response) ->
			matches = response.headers.get('Content-Range').match(/^(\w+) (\d+||\*)\/(\d+||\*)$/)
			###
				@see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.16

				matches[1] is the range type
				matches[2] is the range type
				matches[3] is the total
			###
			test.assertEquals Number(matches[3]), data.number, 'Create a lot of related entities'

	casper.then ->
		@inspired.delete "/articles/#{data.article.uuid}/comments.json"
		@then (response) ->
			test.assertEquals response.status, 200, "Delete All Related"

	casper.then ->
		@inspired.delete "/articles/#{data.article.uuid}.json"
		@then (response) ->
			test.assertEquals response.status, 200, "Delete Base"

	casper.run ->
		test.done()