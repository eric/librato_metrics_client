# Librato Metrics Client

## Overview

This is currently purely experimental. It's hard to tell from here if it will
turn into anything useful.

There are a few goals:

* Make it easy to run one-off code
* Make it easy to run code on a regular basis
* Have multiple instances of code run with different configuration

We'll see how it goes.

## Installing

Right now there is no released gem. In the mean time, you can download and 
run it locally with:

    $ git clone https://eric@github.com/eric/librato_metrics_client.git
    $ cd librato_metrics_client && bundle


## Working Commands

Add your credentials:

    $ bundle exec lmetrics config user.email email@gmail.com
    $ bundle exec lmetrics config user.token \
        9cbedb645496b9a6b13c63c4bc3d1b95f02b3dbb

Run a probe once in the foreground:

    $ bundle exec lmetrics probe run plugins/disk_usage.rb

Run a probe every 10 seconds in the foreground:

    $ bundle exec lmetrics probe run --interval=10 plugins/disk_usage.rb

Set the prefix for the metrics that are generated:

    $ bundle exec lmetrics probe run --prefix=disk_usage plugins/disk_usage.rb


## Possible Future Example Commands


Install a plugin:

    $ lmetrics plugin add http_check plugins/http_check.rb

Add a check for the plugin:

    $ lmetrics probe add local_check http_check -s host=localhost

Run the agent:

    $ lmetrics agent run

