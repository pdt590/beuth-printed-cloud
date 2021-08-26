#!/bin/sh

# Create folders
MQTT_DIR=${DATA_DIR}/mosquitto
INFLUX_DIR=${DATA_DIR}/influxdb
GRAFANA_DIR=${DATA_DIR}/grafana

[ ! -d "$MQTT_DIR" ] && mkdir -p ${DATA_DIR}/mosquitto/data ${DATA_DIR}/mosquitto/log
[ ! -d "$INFLUX_DIR" ] && mkdir -p ${DATA_DIR}/influxdb
[ ! -d "$GRAFANA_DIR" ] && mkdir -p ${DATA_DIR}/grafana

sudo chown -R 1883:1883 ${DATA_DIR}/mosquitto
sudo chown -R 472:472 ${DATA_DIR}/grafana