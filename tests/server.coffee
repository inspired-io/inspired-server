casper.test.begin 'Server tests', 9, (test) ->
	casper.start()

	data = {
		entities: {
			article: null
			comment1: null
			comment2: null
		}
		content: {
			text1: 'What a cool description'
			text2: 'This is the best body text in the whole wide world'
		}
	}

	###
		POST /articles
    Create `article`
	###
	casper.then ->
		@open 'http://localhost:8765/articles.json', {
			method: 'POST'
			data: JSON.stringify {
				body: data.content.text1
			}
		}
		@then ->
			data.entities.article = JSON.parse @getPageContent()
			test.assertEquals data.entities.article.body, data.content.text1, "Create `article`"

	###
    GET /articles/[UUID]
    Fetch `article`
	###
	casper.then ->
		@open "http://localhost:8765/articles/#{data.entities.article.uuid}.json", {
			method: 'GET'
		}
		@then ->
			entity = JSON.parse @getPageContent()
			test.assertEquals entity, data.entities.article, "Fetch `article`"

	###
		GET /articles
    Check `article` now exists in list
	###
	casper.then ->
		@open 'http://localhost:8765/articles.json', {
			method: 'GET'
		}
		@then ->
			list = JSON.parse @getPageContent()
			matches = (key for key, values of list._links when key is data.entities.article.uuid)
			test.assertEquals matches.length, 1, "Check `article` now exists in list"

	###
    POST /comments
    Add `comment` through the "generic" endpoint
  ###
	casper.then ->
		@open 'http://localhost:8765/comments.json', {
			method: 'POST'
			data: JSON.stringify {
				body: data.content.text1
				article: data.entities.article.uuid
			}
		}
		@then ->
			data.entities.comment1 = JSON.parse @getPageContent()
			test.assertEquals data.entities.comment1.body, data.content.text1, 'Add `comment` through the "generic" endpoint'

	###
		GET /comments
		Check `comment` now exists in "generic" list
	###
	casper.then ->
		@open 'http://localhost:8765/comments.json', {
			method: 'GET'
		}
		@then ->
			list = JSON.parse @getPageContent()
			matches = (key for key, values of list._links when key is data.entities.comment1.uuid)
			test.assertEquals matches.length, 1, 'Check `comment` now exists in "generic" list'

	###
    POST /articles/[UUID]/comments
    Add `comment` through the "specific" endpoint
    (should link to article automatically)
  ###
	casper.then ->
		@open "http://localhost:8765/articles/#{data.entities.article.uuid}/comments.json", {
			method: 'POST'
			data: JSON.stringify {
				body: data.content.text2
				#article: data.entities.article.uuid
			}
		}
		@then ->
			data.entities.comment2 = JSON.parse @getPageContent()
			test.assertEquals data.entities.comment2.body, data.content.text2, 'Add `comment` through the "specific" endpoint'

	###
		GET /articles/[UUID]/comments
    Check `comment` now exists in "specific" list
	###
	casper.then ->
		@open "http://localhost:8765/articles/#{data.entities.article.uuid}/comments.json", {
			method: 'GET'
		}
		@then ->
			list = JSON.parse @getPageContent()
			matches = (key for key, values of list._links when key is data.entities.comment2.uuid)
			test.assertEquals matches.length, 1, 'Check `comment` now exists in "specific" list'

	###
		DELETE /comments/[UUID]
    Delete `comment`
	###
	casper.then ->
		@open "http://localhost:8765/comments/#{data.entities.comment1.uuid}.json", {
			method: 'DELETE'
		}
		@then (response) ->
			test.assertEquals response.status, 200, "Delete `comment`"

	###
		GET /comments
    Check `comment` is now gone from list
	###
	casper.then ->
		@open 'http://localhost:8765/comments.json', {
			method: 'GET'
		}
		@then ->
			list = JSON.parse @getPageContent()
			matches = (key for key, values of list._links when key is data.entities.comment1.uuid)
			test.assertEquals matches.length, 0, "Check `comment` is now gone from list"

	casper.run ->
		test.done()