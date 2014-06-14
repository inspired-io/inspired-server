class User extends App.Entity.Default
	username: new App.Field.String
	password: new App.Field.Password
	profile: new App.Field.HasOne {
		references: -> 'profiles'
	}

module.exports = User