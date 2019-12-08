# PrintED cloud with MQTT, InfluxDB, Grafana and Telegraf

## Projects

- `mosquitto`: Mosquitto Docker container configuration files
- `telegraf`: Telegraf Docker container configuration files

## Setup

### Mosquitto + InfluxDB + Telegraf + Grafana 

Make sure you have `docker` and `docker-compose` installed.  
For the example, a Raspberry Pi 3 B+ with Raspbian will be used.

Set the `DATA_DIR` environment variable to the path where will be stored local data (e.g. in `/tmp`):

```sh
export DATA_DIR=/tmp
```

Create data directories with write access:

```sh
mkdir -p ${DATA_DIR}/mosquitto/data ${DATA_DIR}/mosquitto/log ${DATA_DIR}/influxdb ${DATA_DIR}/grafana
sudo chown -R 1883:1883 ${DATA_DIR}/mosquitto
sudo chown -R 472:472 ${DATA_DIR}/grafana
```

Run docker compose:

```sh
$ docker-compose up -d
```

Mosquitto username and passwords are `mqttuser` and `mqttpassword`.
To change these, see the `Optional: Update mosquitto credentials` section.

## Sensors

Sensors should send data to the mosquitto broker to the following topic:  
`sensors/{peripheralName}/{temperature|humidity|battery|status}`.  
For example: `sensors/bme280/temperature`.

## Grafana Setup (ToDo)

## Optional: Update Mosquitto Credentials

To change default MQTT username and password, run the following, replacing `[USER]` and `[PASSWORD]`:

```sh
$ cd mosquitto
$ echo -n "" > users
$ docker run --rm -v `pwd`/mosquitto.conf:/mosquitto/config/mosquitto.conf -v `pwd`/users:/mosquitto/config/users eclipse-mosquitto:1.6 mosquitto_passwd -b /mosquitto/config/users [USER] [PASSWORD]
$ cd -
```

Then, update the `MQTT_USER` and `MQTT_PASSWORD` constants in all the subdirectories, and launch docker compose again.


## Alternative: Using Docker Manually Instead of Docker Compose

```sh
$ cd mosquitto
$ docker run -d -p 1883:1883 -v $PWD/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $PWD/users:/mosquitto/config/users -v $DATA_DIR/mosquitto/data:/mosquitto/data -v $DATA_DIR/mosquitto/log:/mosquitto/log --name mosquitto eclipse-mosquitto:1.6
$ cd -

$ docker run -d -p 8086:8086 -v $DATA_DIR/influxdb:/var/lib/influxdb --name influxdb influxdb:1.7

$ cd telegraf
$ docker run -d -v $PWD/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf --name telegraf telegraf:1.10
$ cd -

$ docker run -d -p 3000:3000 -v $DATA_DIR/grafana:/var/lib/grafana --name=grafana grafana/grafana:5.4.3
```