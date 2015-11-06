  # RSMQ-Monitor
A tool to monitor one or more Redis Simple Message Queues

## Concept

Multiple queues will be polled by a defined interval for their stats to generate a history over time of the following metrics:

 - **count** The current count of messages within the queue
 - **received** The count of messages the queue received
 - **sent** The count of messages the queue could process

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

## Methods
---
### REST
- **listQueues**
  ```
  GET /api/v1/list

  Content-Type: application/json
  Response: {
    keys: ["key1", "key2", ...]
  }
  ```

All methods below have the following (optional) QueryParams: **?start=bla&end=blubb&group=xy**
  * **`start`**: (*String* default: `now() - 1h`): a timestamp plus the unit eg: "1446818686156ms"
  * **`end`**: (*String* default: `now()`): same as `start`
  * **`group`**: (*String*): time interval to group by (mean values are taken for the specified intervals) eg: "1m" to group by 1 minutes or "15m", "1h", "20s"
  * **`limit`**: (*Number*): the maximum number of timeslots in the answer

- **getAllStats**
  ```
  GET /api/v1/:KEY
  Content-Type: application/json
  Response:
  {
    start: 1446246813
    end: 1446646913
    group: "5m"
    stats: [
      { time: 1446246813, count: 112, recv: 13023, sent: 12911 },
      { time: 1446247113, count: 0, recv: 13023, sent: 13023 },
      { time: 1446247413, count: 45, recv: 13068, sent: 13023 },
      ...
    ]
  }
  ```
- **getCount**
  ```
  GET /api/v1/:KEY/count
  Content-Type: application/json
  Response:
  {
    start: 1446246813
    end: 1446646913
    group: "5m"
    stats: [
      { time: t, count: x },
      { time: t, count: x },
      { time: t, count: x },
      ...
    ]
  }
  ```
- **getReceived**
  ```
  GET /api/v1/:KEY/recv
  Content-Type: application/json
  Response:
  {
    start: 1446246813
    end: 1446646913
    group: "5m"
    stats: [
      { time: t, recv: y },
      { time: t, recv: y },
      { time: t, recv: y },
      ...
    ]
  }
  ```
- **getSent**
  ```
  GET /api/v1/:KEY/sent
  Content-Type: application/json
  Response:
  {
    start: 1446246813483
    end: 1446646913483
    group: "5m"
    stats: [
      { time: t, sent: z },
      { time: t, sent: z },
      { time: t, sent: z },
      ...
    ]
  }
  ```
### Influx-connector
- **writeStats**
- **getStats**
- **dropStats**

## Development
TODO:
fix tests
more tests
Influx-connector.getStats
rest model
rest api


Build with `grunt build`
Watch with `grunt watch` or `grunt bwatch` (build and watch then)
Start with `NODE_ENV=development DEBUG=rsmq* node-dev app/aggregator.js`
