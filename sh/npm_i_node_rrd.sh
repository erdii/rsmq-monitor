#!/bin/sh
cd /rrd/node_modules
rm -rf node_rrd
git clone https://github.com/Orion98MC/node_rrd
mv node_rrd ../node_modules/
cd ../node_modules/node_rrd
npm i --unsafe-perm .
