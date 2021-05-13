#!/bin/sh
docker run -it --rm --link=nats-server -v $(pwd)/..:/home/mqtt_demo synadia/nats-box
