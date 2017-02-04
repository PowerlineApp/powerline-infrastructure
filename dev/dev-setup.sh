#!/bin/bash

# simple dev-setup script for vagrant
# add master bootstrap here if needed
#

sudo mkdir -p /etc/salt/gpgkeys
sudo ln -s /vagrant/dev/gpgkeys /etc/salt/gpgkeys
sudo ln -s /vagrant/dev/etc/s3.conf /etc/salt/master.d/s3.conf
