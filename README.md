# RSMQ-Monitor
A tool to monitor one or more Redis Simple Message Queues on the same redis-server

# **WARNING** THIS MODULE ISN'T EVEN IN ALPHA PHASE **WARNING**

## Specs
What do we need?

monitor rsmq stats for:
* total number of messages
	* ever received									| COUNTER
	* ever sent to workers					| COUNTER
* number of messages in queue			| GAUGE


2 modules?
* aggregator:
	aggregates stats and updates the rrd

* stats:
	displays the stats (http server or cmdline?)


## Notes
* rrdtool cannot create a round-robin-database on a vbox filesystem

## Maybe?

alert:
* if # of msgs gets too high
* if rcvd and sent msgs diverge too much
