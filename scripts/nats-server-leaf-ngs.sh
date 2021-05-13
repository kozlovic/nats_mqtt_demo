#!/bin/sh
docker run -it --rm --name=nats-server -v $(pwd)/..:/home/mqtt_demo -p 4222:4222 -p 1883:1883 nats:alpine -c /home/mqtt_demo/conf/leaf.conf
   
