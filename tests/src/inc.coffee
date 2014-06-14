casper.inspired = {
	findInList: (uuid, list) ->
		(key for key, values of list._links when key is uuid)

	url: (path) ->
		"http://localhost:#{casper.cli.options.port}#{path}"

	head: (path) ->
		casper.thenOpen casper.inspired.url(path), {
			method: 'HEAD'
		}

	get: (path) ->
		casper.thenOpen casper.inspired.url(path), {
			method: 'GET'
		}

	post: (path, data) ->
		casper.thenOpen casper.inspired.url(path), {
			method: 'POST'
			data: JSON.stringify data
		}

	put: (path, data) ->
		casper.thenOpen casper.inspired.url(path), {
			method: 'PUT'
			data: JSON.stringify data
		}

	delete: (path) ->
		casper.thenOpen casper.inspired.url(path), {
			method: 'DELETE'
		}
}