# PrintED cloud with MQTT, InfluxDB, Grafana and Telegraf

![achitecture](/img/architecture.png "System Achitecture")

## Compatibility

- [beuth-printed-sensor/clip](https://github.com/pdthang/beuth-printed-sensor/tree/clip) using LIS3DH and BME680 sensors
- [beuth-printed-app/clip](https://github.com/pdt590/beuth-printed-app)
- [beuth-printed-gateway/master](https://github.com/pdt590/beuth-printed-gateway)
- [beuth-printed-cloud/master](https://github.com/pdt590/beuth-printed-cloud)

## Reference

- http://nilhcem.com/iot/home-monitoring-with-mqtt-influxdb-grafana
- https://github.com/Nilhcem/home-monitoring-grafana
- https://github.com/rawkode/influxdb-examples/blob/master/telegraf/mqtt/docker-compose.yml
- https://community.influxdata.com/t/mqtt-input-example-needed/9840

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

Move to main folder

```sh
cd beuth-printed-cloud
```

Run docker compose:

```sh
$ docker-compose up -d
```

Stops containers and removes containers, networks, volumes, and images created by up:

```sh
$ docker-compose down
```

Mosquitto username and password are `mqttuser` and `mqttpassword`.
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
    - In the case of `data_format = "value"`
      - FROM: `[default] [mqtt_consumer] WHERE [topic]=[sensors/test]`
      - SELECT: `field(value)`
    - In the case of `data_format = "json"`
      - FROM: `[default] [mqtt_consumer] WHERE [topic]=[sensors/test]` or you can choose `WHERE [tag_key]` in which `tag_key` is in `tag_keys` of `telegraf.conf`
      - SELECT: `field(msg_value)` if json data is `{"msg": {"value": 100}}` or `field(json_string_field)` in which `json_string_field` is in `json_string_fields` of `telegraf.conf`
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
$ Ctrl + d
```

## TODO

- Fix auto deployment issue when restarting server
- Fix persistance storage issue
- Fix issue `WARNING: The DATA_DIR variable is not set. Defaulting to a blank string.`


## Docker command

- Run docker compose
  
  ```bash
  docker-compose up -d
  ```

- If you want to update config

  ```bash
  # Stop running containers
  docker-compose stop

  # Change config

  # Re-run again
  docker-compose up -d
  ```

- [Other commands](https://docs.docker.com/compose/reference/overview/)

  ```bash
  # Builds, (re)creates, starts, and attaches to containers for a service.
  docker-compose up

  # Stops containers and removes containers, networks created by up.
  docker-compose down

  # Stops containers and removes containers, networks, volumes, and images created by up.
  docker-compose down --rmi all -v --remove-orphans

  # Starts existing containers for a service.
  docker-compose start

  # Stops running containers without removing them.
  docker-compose stop

  # Pauses running containers of a service.
  docker-compose pause

  # Unpauses paused containers of a service.
  docker-compose unpause

  # Lists containers.
  docker-compose ps

  # View active containers
  docker ps

  # View all containers — active and inactive
  docker ps -a

  # View the latest container you created
  docker ps -l

  # Start container
  docker start ${CONTAINER_ID OR NAME}

  # Stop container
  docker stop ${CONTAINER_ID OR NAME}

  # Restart container
  docker restart ${CONTAINER_ID OR NAME}

  # Remove container
  docker rm ${CONTAINER_ID OR NAME}

  # Remove all stopped containers
  docker rm $(docker ps -a -q)

  # Remove all containers including its volumes use
  docker rm -vf $(docker ps -a -q)

  # List the Docker images
  docker images

  # Remove image
  docker rmi ${IMAGE_ID OR NAME}

  # Remove all images
  # Remember, you should remove all the containers before removing all the images from which those containers were created.
  docker rmi -f $(docker images -a -q)
  ```
