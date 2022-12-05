#!/bin/bash

task cluster_up
task configs
task bootstrap_admiral
task shared:bootstrap_captain
sleep 1800 # wait for captain to be ready
task shared:send_credentials_to_slack
sleep 3600 # Give you an opportunity to look at everything.
task clean
