# RSMQ-Monitor
A tool to monitor one or more Redis Simple Message Queues on the same redis-server

## Concept

Multiple queues will be polled by a defined interval for their stats to generate a history over time of the following metrics:

 - **count** The current count of messages within the queue
 - **new** The count of messages the queue received during the last interval
 - **processed** The count of messages the queue could process during the last interval

The System will be split into multiple modules to increase the stability.

 - **Aggregator**: A process that polls the queues and pushes the data into a shared RR-database ([RRDtool](http://oss.oetiker.ch/rrdtool/index.en.html))
 - **Stats**: A server that will query the database and returns a graph as an image or just the data.

## install
 .....

## Config

To configure all the systems a config.json has to be defined with the following settings.

- **rrdtool**: *( `String` default: `rrdtool`)*: the path to the rrdtool binary
- **dbfolder**: *( `String` default: `./dbs/`)*: the RR-database folder path - one RRD per `queues[].key` in config
- **queue_default**: *( `Object` )*: A default rsmq configuration
	- **queue_default.host**: *( `String` default: `127.0.0.1` )*: The default host for all queues
	- **queue_default.port**: *( `Number` default: `6379` )*: The default port for all queues
	- **queue_default.ns**: *( `String` default: `rsmq` )*: The default namespace for all queues
	- **queue_default.interval**: *( `Number` default: `1` )*: the poll interval in seconds
- **queues**: *( `Object[]` )*:
	- **queues[].key**: *( `String` **required** )*: the queues identifier that will be displayed with the stats
	- **queues[].qname**: *( `String` **required** )*: the queues qname on the rsmq server
	- **queues[].host**: *( `String` )*: the queues rsmq host *defaults to queue_default.host*
	- **queues[].port**: *( `String` )*: the queues rsmq port *defaults to queue_default.port*
	- **queues[].ns**: *( `String` )*: the queues rsmq namespace *defaults to queue_default.ns*
	- **queues[].interval**: *( `Number`)*: the poll interval in seconds *defaults to queue_default.interval*  
	TODO:  add additional rrd archive settings

## run

### Aggregator

`node app/aggregator.js`

### Stats

`node app/stats.js`

## Methods

### Aggregator

....

### RRD-connector

- **create**
- **recreate?**
- **add**
- **stats**
- **graph**



## Development
	.... vagrant

* rrdtool cannot create a round-robin-database on a vbox filesystem


Start with `NODE_ENV=development DEBUG=rsmq* node-dev app/app.js`
