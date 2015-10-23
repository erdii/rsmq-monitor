#!/bin/sh
netstat -rn | grep '^0.0.0.0' | cut -d ' ' -f10
