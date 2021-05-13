#!/bin/sh
host="broker.hivemq.com"
link=""
if [ "$1" == "nats" ]; then
   host=nats-server
   link="--link=nats-server"
fi
docker run -it --rm $link efrecon/mqtt-client pub -h $host -u mqtt_command -t "NATS/MQTT/Demo/Command/$2" -m "1"

