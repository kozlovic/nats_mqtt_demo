#!/bin/sh
url="mqtt://broker.hivemq.com"
link=""
if [ "$1" == "nats" ]; then
   url="nats://nats-server"
   link="--link=nats-server"
fi
docker run -it --rm $link -e SITE=NATS -e AREA=MQTT -e LINE=Demo -e MQTT_URL=$url -e MQTT_USERNAME=mqtt_demo spruiktec/packml-simulator 
