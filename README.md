# RSMQ-Monitor
A tool to monitor one or more Redis Simple Message Queues on the same redis-server

## Concept

Multiple queues will be polled by a defined interval for their stats to generate a history over time of the following metrics:

 - **count** The current count of messages within the queue
 - **new** The count of messages the queue received during the last interval
 - **processed** The count of messages the queue could process during the last interval

The System will be split into multiple modules to increase the stability.

 - **Aggregator**: A process that polls the queues and pushes the data into an InfluxDB instance ([InfluxDB](https://influxdb.com/))
 - **Stats**: A server that will query the database and returns a graph as an image or just the data.

## install
TODO

## Config

To configure all the systems a config.json has to be defined with the following settings.

- **influx**: *( `Object` )*: The influx connection options
  - **host**: *( `String` default: `127.0.0.1` )*: the InfluxDB host
  - **port**: *( `Number` default: `8086` )*: the InfluxDB http-API port
  - **database**: *( `String` default: `rsmq_monitor` )*: the DB name
  - **username**: *( `String` default: null)*: the DB username *(can also be set via envvar DBUSER)*
  - **password**: *( `String` default: null)*: the DB password *(can also be set via envvar DBPASS)*
- **queue_defaults**: *( `Object` )*: A default rsmq configuration
	- **queue_defaults.host**: *( `String` default: `127.0.0.1` )*: The default host for all queues
	- **queue_defaults.port**: *( `Number` default: `6379` )*: The default port for all queues
	- **queue_defaults.ns**: *( `String` default: `rsmq` )*: The default namespace for all queues
	- **queue_defaults.interval**: *( `Number` default: `1` )*: the poll interval in seconds
- **queues**: *( `Object[]` )*:
	- **queues[].key**: *( `String` **required** )*: the queues identifier that will be displayed with the stats
	- **queues[].qname**: *( `String` **required** )*: the queues qname on the rsmq server
	- **queues[].host**: *( `String` )*: the queues rsmq host *defaults to queue_defaults.host*
	- **queues[].port**: *( `String` )*: the queues rsmq port *defaults to queue_defaults.port*
	- **queues[].ns**: *( `String` )*: the queues rsmq namespace *defaults to queue_defaults.ns*
	- **queues[].interval**: *( `Number`)*: the poll interval in seconds *defaults to queue_defaults.interval*  
	TODO:  add additional retention settings

## run

### Aggregator

`node app/aggregator.js`

### Stats

`node app/stats.js`

## Methods

### Aggregator
....

### Influx-connector
- **writeStats**
- **getStats**
- **dropStats**


## Development
TODO

Start with `NODE_ENV=development DEBUG=rsmq* node-dev app/app.js`
