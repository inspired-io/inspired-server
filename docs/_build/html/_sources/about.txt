=======
 About
=======

-------------
 What is it?
-------------

inspired-server is the first component of the inspired JS toolset.
You should check out the roadmap to get an idea of where we're going.

Fully RESTful entity server (~50%)
==================================

Create your entities, then use any RESTful capable tool to manage your data.
inspired-server supports all the HTTP verbs, implements HATEOAS & HAL and uses HTTP status codes semantically.

.. note::
   We're still implementing some of the methods but we're close to finishing!

Code-on-Demand: Use your JS models anywhere
===========================================

Models are shared between clients and server so write your code once and use it everywhere.
From validation logic to computed properties, you shouldn't have to repeat yourself.
Just include your code on any platform that can run Javascript.
We've tested running clients in Webkit and NodeJS.

DB Schema generated automatically from your models
==================================================

Everything is derived from your models.
Add or change fields, and the underlying database gets updated when you run your app!

----------------------
 Notes & Requirements
----------------------

CoffeeScript vs JavaScript
==========================

We recommend using CoffeeScript, and that's what we use in the examples.
Though plain Javascript works too, we haven't documented that yet, but we accept pull requests, so you can!
Read more about why in the design decisions section.

PostgreSQL
==========

I'm sure this will be everyone's first complaint.
Yes, we will add MySQL and MongoDB support soon but none of the DBAL for NodeJS were good enough for us,
so we're using what we think is the most versatile and production-ready DB.
If you don't agree, write a good DBAL for inspired-server or don't use this software.