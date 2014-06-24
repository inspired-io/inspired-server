=================
 Getting started
=================

Getting started with inspired-server is really easy.
Make sure you've checked out the installation guide first.

---------------
 Bootstrapping
---------------

Start by creating your bootstrap file.
We decided to name ours `main.coffee` but you can name it whatever you like.

Step by step
============

Step 1: Require the inspired-server app.

.. code-block:: coffeescript

   App = require('inspired-server').App

Step 2: Setup your database connection.

.. code-block:: coffeescript

   db = new App.DB
   db.dsn 'postgres://USERNAME:PASSWORD@HOST/DATABASE'

Step 3: Register your models

.. code-block:: coffeescript

   App.Entity.NameOfMyFirstModel = require './path/to/my-first-model.coffee'
   db.registry 'table_name_and_url_key', App.Entity.NameOfMyFirstModel

.. note::
   Make sure you read the notes about `Models`_.

Step 4: Start the server

.. code-block:: coffeescript

   new App.Server

Putting it all together
=======================

.. code-block:: coffeescript

   App = require('inspired-server').App

   db = new App.DB
   db.dsn 'postgres://USERNAME:PASSWORD@HOST/DATABASE'

   App.Entity.MyModelOne = require './lib/mymodel1.coffee'
   App.Entity.MyModelTwo = require './lib/mymodel2.coffee'
   App.Entity.MyModelThree = require './lib/mymodel3.coffee'

   db.registry 'my_model_one', App.Entity.MyModelOne
   db.registry 'my_model_two', App.Entity.MyModelTwo
   db.registry 'my_model_three', App.Entity.MyModelThree

   new App.Server

.. note::
   Make sure you read the notes about `Models`_.

--------
 Models
--------

Now, it's time to write your models. For example, in `./lib/mymodel1.coffee`:

.. code-block:: coffeescript

   class MyModelOne extends App.Entity.Default
       my_field1: new App.Field.String
       my_field2: new App.Field.Float
       sayHello: ->
           "Hello World"

   module.exports = MyModelOne

.. note::
   You can put your models wherever you want. We put ours in a folder called `lib/`.

.. note::
   For now, you MUST declare your models using the `App.Entity.xxxx` namespace. *

   In future releases you'll be able to use whatever namespace you like,
   which will help prevent conflicts between your own models and community models.

.. note::
   The server currently uses the table name as the url key.

   In future releases it will be possible to specify both independently.

-------------
 Run the app
-------------

.. code-block:: bash

   $ coffee main.coffee

You can now reach your `inspired-server` on http://localhost:8765/.

JavaScript bundles are ready to include in the browser and in node clients here:
* http://localhost:9876/bundle.js
* http://localhost:9876/bundle.min.js
* http://localhost:9876/bundle.dev.js
* http://localhost:9876/bundle.node.js

---------------
 How to use it
---------------

You can browse all your data by pointing your browser to http://localhost:8765/
but there are many other ways to consume your data using the same syntax and API!

Browser App
===========

Write your app directly in the browser.

.. code-block:: html

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


NodeJS App
==========

Include the node bundle in your Node app and you're all set!

The following example is written in CoffeeScript but you can use Javascript if you like.

.. code-block:: coffeescript

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


-------------------------
 Examples & Code samples
-------------------------

Coming soon...

.. To make getting started easy, we've put together some downloadable examples here:
.. https://github.com/inspired-io/inspired-server-examples

