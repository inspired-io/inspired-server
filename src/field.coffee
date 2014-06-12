
class _Base
	default: -> null
	length: -> null
	type: -> null
	multiple: -> false
	unique: -> false
	isForeignKey: -> false
	isValid: (value) ->
		if @length()? and value? and value.length > @length()
			return false
		return true
	constructor: (args) ->
		@[key] = val for key, val of args

class Boolean extends _Base
	type: -> 'boolean'

class Integer extends _Base
	length: -> 10
	type: -> 'integer'

class Date extends _Base
	type: -> 'date'

class MacAddress extends _Base
	type: -> 'macaddr'

class Money extends _Base
	type: -> 'money'
	default: -> '123'

class Float extends _Base
	type: -> 'float8'

class String extends _Base
	length: -> 50
	type: -> 'varchar'

class Text extends _Base
	type: -> 'text'

class Time extends _Base
	type: -> 'time'

class Timestamp extends _Base
	type: -> 'timestamp'

class Uuid extends _Base
	type: -> 'uuid'
	unique: -> true

class Password extends String

class _Relation extends Uuid
	references: -> throw "You must set 'references' for this field"
	isForeignKey: -> true

class HasOne extends _Relation
	multiple: -> false

class HasMany extends _Relation
	multiple: -> true


module.exports = {
	_Base: _Base
	Boolean: Boolean
	Integer: Integer
	Date: Date
	MacAddress: MacAddress
	Money: Money
	Float: Float
	String: String
	Text: Text
	Time: Time
	Timestamp: Timestamp
	Uuid: Uuid
	Password: Password
	HasOne: HasOne
	HasMany: HasMany
}