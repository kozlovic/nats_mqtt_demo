#!/bin/sh
host="broker.hivemq.com"
link=""
if [ "$1" == "nats" ]; then
   host=nats-server
   link="--link=nats-server"
fi
docker run -it --rm $link efrecon/mqtt-client sub -h $host -u mqtt_sub -t "NATS/MQTT/Demo/Admin/#" -v
