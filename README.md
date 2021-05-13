# MQTT Demo

MQTT support in NATS (starting server v2.2.0+) is intended to be an enabling technology allowing users to leverage existing investments in their IoT deployments. Updating software on the edge or endpoints can be onerous and risky, especially when embedded applications are involved.

In greenfield IoT deployments, when possible, we prefer NATS extended out to endpoints and devices for a few reasons. There are significant advantages with security and observability when using a single technology end to end. Compared to MQTT, NATS is nearly as lightweight in terms of protocol bandwidth and maintainer supported clients efficiently utilize resources so we consider NATS to be a good choice to use end to end, including use on resource constrained devices.

In existing MQTT deployments or in situations when endpoints can only support MQTT, using a NATS server as a drop-in MQTT server replacement to securely connect to a remote NATS cluster or supercluster is compelling. You can keep your existing IoT investment and use NATS for secure, resilient, and scalable access to your streams and services.

More information on how MQTT support in NATS Server can be found [here](https://docs.nats.io/nats-server/configuration/mqtt).

This demonstration will show you how easy it is to replace existing MQTT brokers with a NATS Server.

We are going to use some docker images that simulate production of MQTT messages and some MQTT client to consume them.

## Without NATS

We are going to a manufacturing line PackML MQTT Simulator. Information about this project can be found [here](https://github.com/Spruik/PackML-MQTT-Simulator).

This project offers Docker images, so we don't have to build anything.

The `scripts` directory contains scripts that should allow you to run the simulator without having to do anything, expect to have Docker running on your machine.

From the root of this project, follow these instructions:

```
cd scripts
./sim.sh
Unable to find image 'spruiktec/packml-simulator:latest' locally
latest: Pulling from spruiktec/packml-simulator
839b45e0263a: Pull complete
4e998bcc33c0: Pull complete
c22cf2090e91: Pull complete
878525310d1a: Pull complete
d11892d71a6c: Pull complete
8efb30741904: Pull complete
5cbd584d6c8b: Pull complete
12d684da9120: Pull complete
Digest: sha256:32efb17e8b92189bf980e80fba5b6eb22d0fafdf2b5f18d67a7a33cb13e6db3b
Status: Downloaded newer image for spruiktec/packml-simulator:latest
2021-05-13T22:18:54.178Z | info: Initializing
2021-05-13T22:18:54.870Z | info: Connected to mqtt://broker.hivemq.com:1883
2021-05-13T22:18:54.874Z | info: NATS/MQTT/Demo/Status/UnitModeCurrent : Production
2021-05-13T22:18:54.875Z | info: NATS/MQTT/Demo/Admin/MachDesignSpeed : 100
...
```

As you can see from above output, the simulator has by default connected to an MQTT broker on the web (`broker.hivemq.com`).

After a few seconds, you should see something like this:
```
2021-05-13T22:18:58.597Z | info: NATS/MQTT/Demo/Status/StateCurrent : Clearing
2021-05-13T22:19:04.563Z | info: NATS/MQTT/Demo/Status/StateCurrent : Stopped
```

From another shell (but still from the `scripts` directory), let's start the client that will consume the messages:

```
./mqtt-sub.sh
$ ./mqtt-sub.sh
Unable to find image 'efrecon/mqtt-client:latest' locally
latest: Pulling from efrecon/mqtt-client
4c0d98bf9879: Pull complete
2f3d66e1b565: Pull complete
Digest: sha256:02a5909243b71c234545304d247b19c8bc9f6d4ad2373ee508056c57ac32d4f8
Status: Downloaded newer image for efrecon/mqtt-client:latest
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count 0
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/AccCount 0
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/Name Scrap
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/ID 1
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Unit Each
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/ID 3
NATS/MQTT/Demo/Admin/MachDesignSpeed 100
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount 0
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount 0
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/Count 0
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/ID 2
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Name Finished Goods
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Name Raw Material
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/Unit Each
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count 0
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Unit Each
```

Again, from another shell, we will now send commands to the simulator, to first "Reset" its state.
Since this script will run either against the MQTT broker on the web or our NATS server, the first argument will be `""` for this first stage of the demonstration:

```
$ ./command-mqtt.sh "" "Reset"
```

On the simulator shell, you should see this. You have to wait for the "Idle" log line before proceeding:
```
2021-05-13T22:24:00.568Z | info: NATS/MQTT/Demo/Status/StateCurrent : Resetting
2021-05-13T22:24:09.460Z | info: NATS/MQTT/Demo/Status/StateCurrent : Idle
```

We can now ask the simulator to start:

```
./command-mqtt.sh "" "Start"
```

Both simulator and subscriber start to output data:

```
2021-05-13T22:25:04.120Z | info: NATS/MQTT/Demo/Status/StateCurrent : Starting
2021-05-13T22:25:04.400Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 12.322858903265557
2021-05-13T22:25:04.401Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count : 0.20538098172109262
2021-05-13T22:25:04.401Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount : 0.20538098172109262
2021-05-13T22:25:04.402Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count : 0.20538098172109262
2021-05-13T22:25:04.402Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount : 0.20538098172109262
2021-05-13T22:25:05.408Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 24.645717806531113
2021-05-13T22:25:05.408Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count : 0.6161429451632778
2021-05-13T22:25:05.409Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount : 0.6161429451632778
2021-05-13T22:25:05.409Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count : 0.6161429451632778
2021-05-13T22:25:05.410Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount : 0.6161429451632778
2021-05-13T22:25:06.411Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 36.96857670979667
2021-05-13T22:25:06.411Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count : 1.2322858903265557
2021-05-13T22:25:06.411Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount : 1.2322858903265557
2021-05-13T22:25:06.412Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count : 1.2322858903265557
2021-05-13T22:25:06.412Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount : 1.2322858903265557
2021-05-13T22:25:07.412Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 49.29143561306223
```
and
```
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count 0.20538098172109262
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount 0.20538098172109262
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count 0.20538098172109262
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount 0.20538098172109262
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count 0.6161429451632778
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount 0.6161429451632778
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count 0.6161429451632778
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount 0.6161429451632778
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count 1.2322858903265557
```

Let's stop those scripts.

## With Standalone NATS Server

From yet another shell, we will now start a standalone NATS Server.
The configuration that it will be using is pretty simple:

```yaml
server_name: mqtt_demo
jetstream {
   store_dir: datastore
}
mqtt {
   port: 1883
}
```

We simply specify a server name, a directory for the storage of JetStream streams/consumers/etc.. that is needed by MQTT, and the port in which to accept MQTT client connections.

```
$ ./nats-server-standalone.sh
Unable to find image 'nats:alpine' locally
alpine: Pulling from library/nats
540db60ca938: Pull complete
6217a0b59da6: Pull complete
7631199270cb: Pull complete
448706151ceb: Pull complete
Digest: sha256:170d97969e727db1daf870639952e97cc847901f39fb8b8bb6af3f4668777f36
Status: Downloaded newer image for nats:alpine
[1] 2021/05/13 22:28:48.268427 [INF] Starting nats-server
[1] 2021/05/13 22:28:48.268484 [INF]   Version:  2.2.4
[1] 2021/05/13 22:28:48.268492 [INF]   Git:      [924b314]
[1] 2021/05/13 22:28:48.268534 [INF]   Name:     mqtt_demo
[1] 2021/05/13 22:28:48.268564 [INF]   Node:     4ErQeQor
[1] 2021/05/13 22:28:48.268574 [INF]   ID:       NCVQZXR3P4RXYSORFXHFXMCNIFVUSYPQZ4ZVRSAL43ZXZGNW7NF7WSNG
[1] 2021/05/13 22:28:48.268613 [INF] Using configuration file: /home/mqtt_demo/conf/standalone.conf
[1] 2021/05/13 22:28:48.269434 [INF] Starting JetStream
[1] 2021/05/13 22:28:48.269981 [INF]     _ ___ _____ ___ _____ ___ ___   _   __  __
[1] 2021/05/13 22:28:48.270013 [INF]  _ | | __|_   _/ __|_   _| _ \ __| /_\ |  \/  |
[1] 2021/05/13 22:28:48.270025 [INF] | || | _|  | | \__ \ | | |   / _| / _ \| |\/| |
[1] 2021/05/13 22:28:48.270034 [INF]  \__/|___| |_| |___/ |_| |_|_\___/_/ \_\_|  |_|
[1] 2021/05/13 22:28:48.270347 [INF]
[1] 2021/05/13 22:28:48.270358 [INF]          https://docs.nats.io/jetstream
[1] 2021/05/13 22:28:48.270367 [INF]
[1] 2021/05/13 22:28:48.270375 [INF] ---------------- JETSTREAM ----------------
[1] 2021/05/13 22:28:48.270410 [INF]   Max Memory:      2.88 GB
[1] 2021/05/13 22:28:48.270454 [INF]   Max Storage:     23.64 GB
[1] 2021/05/13 22:28:48.270467 [INF]   Store Directory: "datastore/jetstream"
[1] 2021/05/13 22:28:48.270477 [INF] -------------------------------------------
[1] 2021/05/13 22:28:48.271836 [INF] Listening for MQTT clients on mqtt://0.0.0.0:1883
[1] 2021/05/13 22:28:48.272007 [INF] Listening for client connections on 0.0.0.0:4222
[1] 2021/05/13 22:28:48.273425 [INF] Server is ready
```

We will now restart the simulator and subscriber, but this time, pass "nats" as an argument so that they connect to the NATS Server:

```
$ ./sim.sh "nats"
2021-05-13T22:29:42.582Z | info: Initializing
2021-05-13T22:29:42.643Z | info: Connected to nats://nats-server:1883
2021-05-13T22:29:42.645Z | info: NATS/MQTT/Demo/Status/UnitModeCurrent : Production
2021-05-13T22:29:42.646Z | info: NATS/MQTT/Demo/Admin/MachDesignSpeed : 100
2021-05-13T22:29:42.646Z | info: NATS/MQTT/Demo/Status/MachSpeed : 100
2021-05-13T22:29:42.646Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 0
...
```
Notice that it is now connecting to our NATS Server docker image. This line in the NATS Server shows that the simulator connected and caused the NATS Server to create the appropriate JetStream assets for this account:

```
[1] 2021/05/13 22:29:42.634426 [INF] Creating MQTT streams/consumers with replicas 1 for account "$G"
```

Running the subscriber now does not show a difference at all as compared to when we were using a different broker:

```
$ ./mqtt-sub.sh nats
NATS/MQTT/Demo/Admin/MachDesignSpeed 100
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/ID 1
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Name Raw Material
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Unit Each
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count 0
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount 0
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/ID 2
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/Name Scrap
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/Unit Each
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/Count 0
NATS/MQTT/Demo/Admin/ProdDefectiveCount/0/AccCount 0
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count 0
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount 0
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/ID 3
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Name Finished Goods
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Unit Each
```

Before we reset and start the simulator, we are now going to show how MQTT applications can not only connect natively to a NATS Server, but also exchange messages with regular NATS applications.

For that, we are going to use the `nats-box` Docker image and run a NATS subscription:

```
$ ./nats-box.sh
Unable to find image 'synadia/nats-box:latest' locally
latest: Pulling from synadia/nats-box
ba3557a56b15: Pull complete
8591fa42d73d: Pull complete
248f99e65485: Pull complete
417204a428f2: Pull complete
6820ef7b0234: Pull complete
a3ed95caeb02: Pull complete
3b3563957223: Pull complete
Digest: sha256:caf0c9fe15a9a88d001c74fd9d80f7f6fd57474aa243cd63a9a086eda9e202be
Status: Downloaded newer image for synadia/nats-box:latest
             _             _
 _ __   __ _| |_ ___      | |__   _____  __
| '_ \ / _` | __/ __|_____| '_ \ / _ \ \/ /
| | | | (_| | |_\__ \_____| |_) | (_) >  <
|_| |_|\__,_|\__|___/     |_.__/ \___/_/\_\

nats-box v0.5.0
8fe3dc6192e5:~# nats -s nats://nats-server sub "NATS.MQTT.Demo.Admin.>"
22:34:03 Subscribing on NATS.MQTT.Demo.Admin.>
```

Note that we replace `/` by `.` and use `>` to receive any token after `Admin`.

Now we are resetting and then starting the simulator. We will now pass `"nats"` as the first argument:

```
./command-mqtt.sh "nats" "Reset"
```

Again, waiting for `Idle` to be logged in the simulator and then we will send the "Start" command:

```
./command-mqtt.sh "nats" "Start"
```

You should see again data received by the MQTT subscriber:

```
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count 0.20538098172109262
NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount 0.20538098172109262
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count 0.20538098172109262
NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount 0.20538098172109262
```

But also by the NATS subscription:

```
[#1] Received on "NATS.MQTT.Demo.Admin.ProdConsumedCount.0.Count"
Nmqtt-Pub: 0

0.20538098172109262

[#2] Received on "NATS.MQTT.Demo.Admin.ProdConsumedCount.0.AccCount"
Nmqtt-Pub: 0

0.20538098172109262

[#3] Received on "NATS.MQTT.Demo.Admin.ProdProcessedCount.0.Count"
Nmqtt-Pub: 0

0.20538098172109262
```

Let's stop all the scripts

## With NATS Leafnode Server connected to Synadia's NGS

In order to be able to run this part of the demonstration, you would need to create at least a Free Developer account. See the [Synadia](https://synadia.com/ngs/pricing) website for details.

When you have your credentials file, you need to make it a copy, named `test.creds`, and place it in the `creds` directory.

```sh
nats_mqtt_demo ivan$ ls -lrt
total 8
drwxr-xr-x  3 ivan  staff    96 May 10 17:31 creds
drwxr-xr-x  4 ivan  staff   128 May 12 14:58 conf
drwxr-xr-x  8 ivan  staff   256 May 13 15:47 scripts
-rw-r--r--  1 ivan  staff  1116 May 13 16:10 README.md

nats_mqtt_demo ivan$ ls -lrt creds/
total 8
-rw-------  1 ivan  staff  918 May 10 17:31 test.creds
```

Here is what the configuration file look like:
```yaml
leafnodes {
   remotes [
    {
      url: tls://connect.ngs.global:7422
      credentials: "/home/mqtt_demo/creds/test.creds"
    }
   ]
}
server_name: mqtt
jetstream {
  store_dir: datastore
}
mqtt {
  port: 1883
}
```

The difference compared to the standalone is the presence of a `leafnodes{}` block and there you can see that we create a remote connection to NGS, using the credentials file that you have copied in `creds/` in the previous step.

To run the Leafnode server, from the `scripts` directory, run:
```
$ ./nats-server-leaf-ngs.sh
[1] 2021/05/13 22:47:26.432547 [INF] Starting nats-server
[1] 2021/05/13 22:47:26.432611 [INF]   Version:  2.2.4
[1] 2021/05/13 22:47:26.432638 [INF]   Git:      [924b314]
[1] 2021/05/13 22:47:26.432664 [INF]   Name:     mqtt
[1] 2021/05/13 22:47:26.432699 [INF]   Node:     4iXCbC8U
[1] 2021/05/13 22:47:26.432730 [INF]   ID:       NAKFUEP7RZYQJC3MG4AHZQJPGH4ZPX2EKGGRYRG7JVJA7XFRHK46EFD2
[1] 2021/05/13 22:47:26.432764 [INF] Using configuration file: /home/mqtt_demo/conf/leaf.conf
[1] 2021/05/13 22:47:26.433345 [INF] Starting JetStream
[1] 2021/05/13 22:47:26.433652 [INF]     _ ___ _____ ___ _____ ___ ___   _   __  __
[1] 2021/05/13 22:47:26.433666 [INF]  _ | | __|_   _/ __|_   _| _ \ __| /_\ |  \/  |
[1] 2021/05/13 22:47:26.433678 [INF] | || | _|  | | \__ \ | | |   / _| / _ \| |\/| |
[1] 2021/05/13 22:47:26.433687 [INF]  \__/|___| |_| |___/ |_| |_|_\___/_/ \_\_|  |_|
[1] 2021/05/13 22:47:26.433696 [INF]
[1] 2021/05/13 22:47:26.433708 [INF]          https://docs.nats.io/jetstream
[1] 2021/05/13 22:47:26.433718 [INF]
[1] 2021/05/13 22:47:26.433727 [INF] ---------------- JETSTREAM ----------------
[1] 2021/05/13 22:47:26.433741 [INF]   Max Memory:      2.88 GB
[1] 2021/05/13 22:47:26.433752 [INF]   Max Storage:     23.64 GB
[1] 2021/05/13 22:47:26.433765 [INF]   Store Directory: "datastore/jetstream"
[1] 2021/05/13 22:47:26.433776 [INF] -------------------------------------------
[1] 2021/05/13 22:47:26.434608 [INF] Listening for MQTT clients on mqtt://0.0.0.0:1883
[1] 2021/05/13 22:47:26.434673 [INF] Listening for client connections on 0.0.0.0:4222
[1] 2021/05/13 22:47:26.434904 [INF] Server is ready
[1] 2021/05/13 22:47:26.629408 [INF] 52.41.2.230:7422 - lid:4 - Leafnode connection created
```

Notice how it says that it has connected a Leafnode connection.

Steps to start the simulator and MQTT subscription are the same. Note that those clients connect to the local NATS Server, not directly to NGS:

```
$ ./sim.sh "nats"
```
and
```
$ ./mqtt-sub.sh nats
```

and they will produce the same outputs than with the standalone version.

However, for the NATS subscription, we are going to have it connect to NGS instead of locally.

```
8fe3dc6192e5:~# nats -s tls://connect.ngs.global --creds /home/mqtt_demo/creds/test.creds  sub "NATS.MQTT.Demo.Admin.>"
22:50:25 Subscribing on NATS.MQTT.Demo.Admin.>
```

After sending "Reset" and "Start" commands:
```
$ ./command-mqtt.sh "nats" "Reset"
```

```
$ ./command-mqtt.sh "nats" "Start"
```

You should start to see messages being received, including in the nats-box with a NATS client connected somewhere on NGS!

```
[#1] Received on "NATS.MQTT.Demo.Admin.ProdConsumedCount.0.Count"
Nmqtt-Pub: 0

0.20538098172109262

[#2] Received on "NATS.MQTT.Demo.Admin.ProdConsumedCount.0.AccCount"
Nmqtt-Pub: 0

0.20538098172109262

[#3] Received on "NATS.MQTT.Demo.Admin.ProdProcessedCount.0.Count"
Nmqtt-Pub: 0

0.20538098172109262
```

By the way, you can also use a NATS application to send messages that will be received by MQTT clients. Let's use a `nats pub` to send a `Stop` command:

```
~# nats -s tls://connect.ngs.global --creds /home/mqtt_demo/creds/test.creds pub "NATS.MQTT.Demo.Command.Stop" "1"
22:55:46 Published 1 bytes to "NATS.MQTT.Demo.Command.Stop"
```

In the simulator, you should see that the command was received and messages will stop flowing shortly after:

```
2021-05-13T22:55:46.485Z | info: NATS/MQTT/Demo/Status/StateCurrent : Stopping
2021-05-13T22:55:46.628Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 59.44556585162522
2021-05-13T22:55:46.628Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count : 112.05566445906861
2021-05-13T22:55:46.629Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount : 112.05566445906861
2021-05-13T22:55:46.629Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count : 107.2955674912402
2021-05-13T22:55:46.629Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount : 107.2955674912402
2021-05-13T22:55:47.630Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 17.375729923985332
2021-05-13T22:55:47.630Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/Count : 112.3452599578017
2021-05-13T22:55:47.630Z | info: NATS/MQTT/Demo/Admin/ProdConsumedCount/0/AccCount : 112.3452599578017
2021-05-13T22:55:47.631Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/Count : 107.5851629899733
2021-05-13T22:55:47.631Z | info: NATS/MQTT/Demo/Admin/ProdProcessedCount/0/AccCount : 107.5851629899733
2021-05-13T22:55:48.631Z | info: NATS/MQTT/Demo/Status/CurMachSpeed : 0
2021-05-13T22:55:48.863Z | info: NATS/MQTT/Demo/Status/StateCurrent : Stopped
```

This conclude the demonstration.

## Conclusion

As you can see, it is very easy to use NATS Server as a drop-in replacement of any MQTT broker. More importantly, we have shown how MQTT and NATS can exchange messages without the user having to do anything.

Using a Leafnode, you can easily have a local server enabled with MQTT that can connect to a global NATS cluster (Synadia's [NGS](https://synadia.com/ngs) in this case) and have NATS applications (producers or consumers) anywhere in the world be able to interact with your MQTT applications.
