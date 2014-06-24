# inspired-server

`inspired-server` is the first component of the _inspired JS_ toolset.

* Fully RESTful entity server (~50%)
* Code-on-Demand: Use your JS models anywhere
* DB Schema generated automatically from your models

## Documentation

All the documentation is available here: http://inspired-server.readthedocs.org

## Basic usage

* Install `inspired-server` via npm
* Write some models
* Register your models in your app

You can use your models anywhere, like this:

```javascript
// Create an entity
var entity1 = new App.Entity.Article()
entity1.body = "Lorem ipsum..."
entity1.save()
  .then(function() { ... })
  .catch(function() { ... })
  
// Load an entity by UUID
var entity2 = new App.Entity.Article()
entity2.body = "Lorem ipsum..."
entity2.load('xxxxx-xxxx-xxxxx')
  .then(function() { ... })
  .catch(function() { ... })
  
// Check out the docs for collections and entity management
```

Your models will look somewhat like this:

```coffeescript
class MyEntity extends App.Entity.Default
    my_field1: new App.Field.String
	my_field2: new App.Field.Float
	my_field3: new App.Field.Timestamp
	... etc ...

module.exports = MyEntity
```

## Roadmap

The following list in non-exhaustive and items appear in no specific order.
These items will be moved to the issue queue at some point.

* Implement 100% of REST methods
* Reimplement Minify for bundles
* Auth
* Replace Q with faster promises [1]
* Error handling & normalise error responses
* Make us compatible with express and others
* Serve html docs locally
* Modularize & Cleanup code

[1] http://thanpol.as/javascript/promises-a-performance-hits-you-should-be-aware-of/

Once that's done, we'll be tackling separate modules:

* Front-end & Client widgets
* Declare interfaces
* Routers & Templates that can be rendered client-side or on server (SEO)
* More!

## Contributing

Pull requests will be considered here: https://github.com/inspired-io/inspired-server/pulls.
If you want to write substantial functionality, please discuss architecture in a ticket first.

### Coding Standards

The project uses CoffeeScript and tabs only.
More coming soon.

### Running tests

Once you've [installed CasperJS](http://casperjs.readthedocs.org/en/latest/installation.html)
you can run the test suite from the server module's root folder, like this:

`$ ./tests/run [DSN] [REST_PORT] [META_PORT]`

<dl>
    <dt>DSN</dt>
    <dd>
        The connection details for the DB, eg: "postgres://username:password@hostname/database"
        Create an empty DB for testing.
        The tests should always cleanup after themselves.
    </dd>
    <dt>REST_PORT</dt>
    <dd>The port to run the REST server on during the tests</dd>
    <dt>META_PORT</dt>
    <dd>The port to run the META server on during the tests</dd>
</dl>

Here's an example:

`$ ./tests/run 'postgres://root@localhost/inspired_server_tests' 18765 19876`

### Changes to README or other markdown files

Make sure you preview your changes. We recommend using [markable.in](http://markable.in/).

## Support

Use the issue queue on Github here: https://github.com/inspired-io/inspired-server/issues