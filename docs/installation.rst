==============
 Installation
==============

--------------
 Dependencies
--------------

Postgres
========

Create the database you're using in your `main.coffee` file.
Refer to PostgreSQL if you need help with this.

.. code-block:: sql

   CREATE DATABASE [your-db-name];

CoffeeScript
============

Obviously, once you've [installed CoffeeScript](http://coffeescript.org/#installation),
you can start your server like this:

.. code-block:: bash

   $ coffee main.coffee

You can now reach your `inspired-server` on http://localhost:8765/.

-----------------
 inspired-server
-----------------

Install `inspired-server` via NPM:

.. code-block:: bash

   $ npm install inspired-server
