Raplet Template
===============

A [Raplet](http://code.rapportive.com/raplet-docs/) is a tiny web application that is displayed next
to an email, and allows you to implement email-based workflows and provide contextual information
about the sender. The Raplet API is provided by [Rapportive](http://rapportive.com).

This repository contains example code for a Raplet written in Ruby. It works right out of the box
(although it doesn't do anything useful -- it just echoes the information that it was given).
You can use it to experiment with the API, and you can make it the starting point for your own
Raplet. Just clone the repository and start hacking :)


Features
--------

* Show arbitrary content (HTML, CSS & JS) in Gmail next to an email conversation. Rapportive
  requests the Raplet for every contact looked up by the user, passing the contact's email address,
  full name and Twitter username to the Raplet.
* Support for the [metadata protocol](http://code.rapportive.com/raplet-docs/#the_metadata_protocol)
  for description text and images.
* Support for the
  [Raplet configuration protocol](http://code.rapportive.com/raplet-docs/#the_configuration_protocol)
  (an [OAuth2](http://tools.ietf.org/html/draft-ietf-oauth-v2-12) implementation), enabling you to
  securely authenticate the user, ask them whether to authorize access to your application, and
  set any necessary account configuration or user preferences.
* Friendly error handling
* Run the Raplet on your local machine, or on any Ruby hosting platform of your choice (it works out
  of the box on Heroku).


Development setup
-----------------

This template uses [Sinatra](http://www.sinatrarb.com) to serve incoming requests, and
[DataMapper](http://datamapper.org/) to persist Raplet user information to a database.
(Don't worry if you've not used those libraries before -- the way we use them is pretty
straightforward. You could use others instead, e.g. Rails and ActiveRecord, but we think Sinatra and
DataMapper make the code simpler and clearer for something like a Raplet.)

We use [Bundler](http://gembundler.com) for managing gem dependencies. To get all the dependencies
set up on your machine:

    $ git clone git://github.com/rapportive-oss/raplet-template.git && cd raplet-template
    $ gem install bundler
    $ bundle install

When you have the dependencies installed, you can start the Raplet application just by typing:

    $ bundle exec rackup -s thin

in the `raplet-template` directory. This will start a web server on
[localhost:9292](http://localhost:9292). If you visit that URL in your browser, you should be taken
to a page on rapportive.com prompting you to install your new Raplet. (For this to work, you need to
be logged in to Rapportive in Gmail in the same browser.)

Unless you have an environment variable called `DATABASE_URL` defined, the Raplet will use a SQLite
database (in a file called `raplet.sqlite3`) by default. The database is automatically created when
you start the Raplet.

Now jump in and start playing with the code. Please note that if you change any files outside of the
`views` directory, you need to restart the `rackup` process for your change to take effect.


Deployment
----------

This template is set up to work out of the box on [Heroku](http://heroku.com). If you have the
`heroku` command-line tool installed, deploying is simple:

    $ heroku create my-raplet
    $ git push heroku master

Now your Raplet is publicly available at `my-raplet.heroku.com`. It is automatically configured to
use the Heroku Postgres database.

Deploying on other platforms should be straightforward too, provided that you have access to a
database supported by DataMapper (we use Postgres). Be sure to set the `DATABASE_URL` environment
variable (or change the code which initializes the database connections), otherwise you'll end up
using SQLite.


Meta
----

Everything in this repository is available under the terms of the MIT license. See LICENSE for
details.

Feedback, bug reports, patches and pull requests are welcome.
