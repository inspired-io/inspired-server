hal = require 'hal'

class Resource extends hal.Resource
	constructor: (data, router) ->
		if data instanceof App.Entity.Default
			super data, @formatUri @buildUri(data), router
		else if data instanceof App.Collection
			if router.rel
				super {}, @formatUri "/#{router.name}/#{router.id}/#{router.rel}", router
			else
				super {}, @formatUri "/#{router.name}", router
		else
			super {}, "/", router

		if data instanceof App.Entity.Default
			for name, field of data.fields() when field.isForeignKey()
				delete @[name]
				if field.multiple()
					@link name, @formatUri "#{@buildUri(data)}/#{field.references()}", router
				else
					@link name, @formatUri "/#{field.references()}/#{data[name]}", router

		else if data instanceof App.Collection
			@link instance.uuid, @formatUri(@buildUri(instance), router) for instance in data.toArray()
		else
			@link name, "/#{name}" for name in data

	buildUri: (object) ->
		"/#{object._tableName()}/#{object.uuid}"

	formatUri: (uri, router) ->
		uri += ".#{router.format}" if router.format
		return uri


module.exports = {
	Resource: Resource
}