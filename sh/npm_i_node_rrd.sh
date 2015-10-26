#!/bin/sh
cd /vagrant/node_modules
rm -rf node_rrd
git clone https://github.com/Orion98MC/node_rrd
cd node_rrd
npm i --unsafe-perm .
