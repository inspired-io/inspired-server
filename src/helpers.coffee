String.prototype.uppercaseFirst = ->
	@charAt(0).toUpperCase() + @slice(1)

module.exports = {}