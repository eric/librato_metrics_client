# Librato Metrics Client

## Overview

This is currently purely experimental. It's hard to tell from here if it will
turn into anything useful.

There are a few goals:

* Make it easy to run one-off code
* Make it easy to run code on a regular basis
* Have multiple instances of code run with different configuration

We'll see how it goes.


## Example Commands


Install a plugin:

    $ librato_metrics_client plugin add http_check plugins/http_check.rb
    
Add a check for the plugin:

    $ librato_metrics_client probe add local_check plugin:http_check -s host=localhost

Run the agent:

    $ librato_metrics_client agent run


Or skip the whole plugin thing and just run an ad-hoc plugin in the foreground:

    $ librato_metrics_client probe run plugins/http_check.rb --interval=5 -s host=localhost

