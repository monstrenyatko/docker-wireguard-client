WireGuard client Docker image
=============================

[![Build Status](https://travis-ci.org/monstrenyatko/docker-wireguard-client.svg?branch=master)](https://travis-ci.org/monstrenyatko/docker-wireguard-client)

About
=====

[WireGuard](https://www.wireguard.com/) client in the `Docker` container.

Upstream Links
--------------
* Docker Registry @[monstrenyatko/wireguard-client](https://hub.docker.com/r/monstrenyatko/wireguard-client/)
* GitHub @[monstrenyatko/docker-wireguard-client](https://github.com/monstrenyatko/docker-wireguard-client)

Quick Start
===========

Container configures firewall to block all traffic while VPN network is disconnected.

* Prepare `Docker` host kernel

  - The `WireGuard` kernel module must be available in `Docker` host kernel
  - See official installation [instructions](https://www.wireguard.com/install/), usually, it is as trivial as:

  ```sh
    sudo apt install wireguard
  ```

* Configure environment:

  - `WIREGUARD_PORT`: the `WireGuard` server port number to configure firewall rules

    ```sh
      export WIREGUARD_PORT=51820
    ```
  - `WIREGUARD_CLIENT_CONFIG`: path to `config` file:

    ```sh
      export WIREGUARD_CLIENT_CONFIG="<path-to-wireguard-config-file>"
    ```
  - `NET_LOCAL`: [**OPTIONAL**] local network to setup back route rule,
  this is required to allow connections from your local network to the service working over VPN client network:

    ```sh
      export NET_LOCAL="192.168.0.0/16"
    ```
  - `DOCKER_REGISTRY`: [**OPTIONAL**] registry prefix to pull image from a custom `Docker` registry:

    ```sh
      export DOCKER_REGISTRY="my_registry_hostname:5000/"
    ```
* Pull prebuilt `Docker` image:

  ```sh
    docker-compose pull
  ```
* Start prebuilt image:

  ```sh
    docker-compose up -d
  ```
* Stop/Restart:

  ```sh
    docker-compose stop
    docker-compose start
  ```
* Configuration:

  - [**OPTIONAL**] Allow incoming connections to some port from local network:

    + Set `NET_LOCAL` environment variable, see **Configure environment** section
    + Add to `docker-compose.yml` the `ports` section:

      ```yaml
        wireguard-client:
          ports:
            - 8080:8080
      ```
* Start service working over VPN. The simplest way to do this is to utilize the network stack of
  the VPN client container:

  - Add `--network=container:wireguard-client` option to `docker run` command
  - Start service container:

    ```sh
      docker run --rm -it --network=container:wireguard-client alpine:3 /bin/sh
    ```

  **NOTE:** The service container needs to be restarted/recreated when VPN container is restarted/recreated,
  otherwise network connection will not be recovered.

Build own image
===============

* `default` target platform:

  ```sh
    cd <path to sources>
    DOCKER_BUILDKIT=1 docker build --tag <tag name> .
  ```
* `arm/v6` target platform:

  ```sh
    cd <path to sources>
    DOCKER_BUILDKIT=1 docker build --platform=linux/arm/v6 --tag <tag name> .
  ```
