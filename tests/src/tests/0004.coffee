casper.test.begin 'Test 0004 - OneToOne', 6, (test) ->
	data = {
		user: null
		profile: null
		username: 'user1'
		name: 'Firstname Lastname'
		date: {
			start: null
			end: null
		}
	}

	casper.start()

	data.date.start = new Date()

	casper.then ->
		@inspired.post "/users.json", {
			username: data.username
		}
		@then ->
			data.user = JSON.parse @getPageContent()
			test.assertEquals data.user.username, data.username, "Create base entity"

	casper.then ->
		@inspired.post "/profiles.json", {
			name: data.name
		}
		@then ->
			data.profile = JSON.parse @getPageContent()
			test.assertEquals data.profile.name, data.name, 'Create related entity'

	casper.then ->
		data.user.profile = data.profile.uuid
		@inspired.put "/users/#{data.user.uuid}.json", data.user
		@then (response) ->
			test.assertEquals response.status, 200, "Updated Entity"

	casper.then ->
		@inspired.delete "/users/#{data.user.uuid}.json"
		@then (response) ->
			test.assertEquals response.status, 200, "Delete Base"

	casper.then ->
		@inspired.delete "/profiles/#{data.profile.uuid}.json"
		@then (response) ->
			test.assertEquals response.status, 200, "Delete Related Entity"

	casper.then ->
		data.date.end = new Date()
		total = data.date.end - data.date.start
		test.assert (total < 400), "Speed < 400ms (#{total})"

	casper.run ->
		test.done()