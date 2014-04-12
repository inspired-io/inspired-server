# inspired-server

* [What is it?](#what-is-it)
* [Notes & Requirements](#notes--requirements)
* [Basic usage](#basic-usage)
* [Getting started](#getting-started)
* [Documentation](#documentation)
* [Philosophy](#philosophy)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [Support](#support)

## What is it?
`inspired-server` is the first component of the _inspired JS_ toolset.
You should check out the [roadmap](#roadmap) to get an idea of where we're going.
In the meantime, here are the existing features:

### Fully RESTful entity server (~50%)
Create your entities, then use any RESTful capable tool to manage your data.
`inspired-server` supports all the HTTP verbs, impements HATEOAS &
[HAL](http://tools.ietf.org/html/draft-kelly-json-hal-06)
and uses HTTP status codes semantically.

_We're still implementing some of the methods but we're pretty close!_

### Code-on-Demand: Use your JS models anywhere
Models are shared between clients and server so write your code once and use it everywhere.
From validation logic to computed properties, you shouldn't have to repeat yourself.
Just include your code on any platform that can run Javascript.
We've tested running clients in Webkit and NodeJS.

### DB Schema generated automatically from your models
Everything is derived from your models. Add or change fields,
and the underlying database gets updated when you run your app!

## Notes & Requirements

### CoffeeScript vs JavaScript

We recommend using [CoffeeScript](coffeescript.org), and that's what we use in the examples. Though plain Javascript works too, we haven't documented that yet, but we accept pull requests, so you can! Read more about why in the [design decisions](#design-decisions) section.

### PostgreSQL

I'm sure this will be everyone's first complaint. Yes, we will add MySQL and MongoDB
support soon but none of the DBAL for NodeJS were good enough for us, so we're using
what we think is the most versatile and production-ready DB. If you don't agree, write
a good DBAL for `inspired-server` or don't use this software.

## Basic usage

* Install `inspired-server` via NPM (see [Getting Started](#getting-started))
* Write some models
* Register your models in your app

What your models will look like:

```coffeescript
class MyEntity extends App.Entity.Default
	my_field1: new App.Field.String
	my_field2: new App.Field.Float
	my_field3: new App.Field.Timestamp
	... etc ...

module.exports = MyEntity
```

## Getting started

<!--
To make getting started easy, we've put together some downloadable examples here:
https://github.com/inspired-io/inspired-server-examples
-->

Install `inspired-server` via NPM:

```
$ npm install inspired-server
```

In your `main.coffee` file, you need to start the app and add your models.

*Please note* that at this stage, you MUST declare your models
using the `App.Entity.xxxx` syntax.

```coffeescript
App = require('inspired-server').App

App.Entity.MyModelOne = require './lib/mymodel1.coffee'
App.Entity.MyModelTwo = require './lib/mymodel2.coffee'
App.Entity.MyModelThree = require './lib/mymodel3.coffee'

db = new App.DB
db.dsn 'postgres://USERNAME:PASSWORD@HOST/DATABASE'
db.registry 'my_model_one', App.Entity.MyModelOne
db.registry 'my_model_two', App.Entity.MyModelTwo
db.registry 'my_model_three', App.Entity.MyModelThree

new App.Server
```

Now, it's time to write your models. For example, in `./lib/mymodel1.coffee`:

```coffeescript
class MyModelOne extends App.Entity.Default
	my_field1: new App.Field.String
	my_field2: new App.Field.Float
	sayHello: ->
		"Hello World"

module.exports = MyModelOne
```

Repeat that for `MyModelTwo` and `MyModelThree`.

Create the database you're using in your `main.coffee` file.
Refer to PostgreSQL if you need help with this.

```
CREATE DATABASE [your-db-name];
```

Obviously, once you've [installed CoffeeScript](http://coffeescript.org/#installation),
you can start your server like this:

```
$ coffee main.coffee
```

You can now reach your `inspired-server` on http://localhost:8765/.

JavaScript bundles are ready to include in the browser and in node clients here:
* http://localhost:9876/bundle.js
* http://localhost:9876/bundle.min.js
* http://localhost:9876/bundle.dev.js
* http://localhost:9876/bundle.node.js

### Use in the browser

```
<script src="http://localhost:9876/bundle.dev.js"></script>
<script>
var a = new App.Entity.MyModelOne();
a.my_field1 = "A description";
a.my_field2 = 1.5;
a.save().then(function() {
	console.log(a);
});

var b = new App.Entity.MyModelOne();
b.load('a-uuid-that-exists-in-the-db').then(function() {
	console.log(b);
});
</script>
```

### Use in a NodeJS client (in CoffeeScript)

```
http = require 'http'

http.get {host: 'localhost', port: 9876, path: '/bundle.node.js'}, (res) ->
	data = ''
	res.on 'data', (chunk) -> data += chunk
	res.on 'end', ->
		eval data
		example()

example = ->
	c = new App.Entity.MyModelOne
	c.load 'grab-a-uuid-from-the-db-after-calling-save'
		.then ->
			c.description = "My models work everywhere!"
			c.save()
		.then ->
			console.log 'Saved'
```


## Documentation

Coming soon.

## Philosophy

Coming soon.

### Design decisions

Coming soon.

## Roadmap

The following list in non-exhaustive and items appear in no specific order.
These items will be moved to the issue queue at some point.

* Implement 100% of REST methods
* Reimplement Minify for bundles
* Auth
* Replace Q with faster promises [1]
* Error handling & normalise error responses
* Modulize & Cleanup code

[1] http://thanpol.as/javascript/promises-a-performance-hits-you-should-be-aware-of/

Once that's done, we'll be tackling separate modules:

* Front-end & Client widgets
* Declare interfaces
* Routers & Templates that can be rendered client-side or on server (SEO)
* More!

## Contributing

Pull requests will be considered here: https://github.com/inspired-io/inspired-server/pulls.
If you want to write substantial functionality, please discuss architecture in a ticket first.

The project uses CoffeeScript and tabs only.

More coming soon.

## Support

Use the issue queue on Github here: https://github.com/inspired-io/inspired-server/issues