# PrintED cloud with MQTT, InfluxDB, Grafana and Telegraf

## Projects

- `mosquitto`: Mosquitto Docker container configuration files
- `telegraf`: Telegraf Docker container configuration files

## Setup

### Setup server and docker

[01. Initial Server Setup with Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04)

[02. How to Set Up SSH Keys on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-1804)

[03. How To Install and Use Docker on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04)

[04. How To Install Docker Compose on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04)

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

Stops containers and removes containers, networks, volumes, and images created by up:

```sh
$ docker-compose down
```

Mosquitto username and password are `mqttuser` and `mqttpassword`
To change these, see the `Optional: Update mosquitto credentials` section.

## Sensors

- Sensors has to use username and password being `mqttuser` and `mqttpassword`.
- Sensors should send data to the mosquitto broker to the following topic:  
`sensors/{peripheralName}/{temperature|humidity|battery|status}`.  
For example: `sensors/bme280/temperature`.

## Grafana

- Access Grafana from `http://<host ip>:3000`
- Log in with user/password `admin/admin`
- Go to Configuration > Data Sources
- Add data source (InfluxDB)
  - Name: `InfluxDB`
  - URL: `http://influxdb:8086`
  - Database: `telegraf`
  - User: `root`
  - Password: `root`
  - Save & Test
- Create a Dashboard
  - Add Graph Panel
  - Edit Panel
  - General
    - Title: `Test`
  - Metrics
    - Data Source: InfluxDB
    - FROM: `[default] [mqtt_consumer] WHERE [topic]=[sensors/test]`
    - SELECT: `field(value)`
    - FORMAT AS: `Time series`
  - Display
    - Draw modes: Lines
    - Stacking & Null value
      - Null value: `connected`
  - Time range
    - Last: `1h`
    - Amount: `1s`

- Change refresh time (Top-Right Monitor)
  - `Last 6 hours`
  - Refreshing every `5s`

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

## Go inside a docker

```sh
# Use either docker run or use docker exec with the -i (interactive) flag to keep stdin open and -t to allocate a terminal
$ docker exec -it influxdb bash

# To quit
$ Ctrl + q
```