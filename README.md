# docker-spring-micro-services
[![CircleCI](https://circleci.com/gh/bednar/docker-spring-micro-services.svg?style=shield&circle-token=:circle-ci-badge-token)](https://circleci.com/gh/bednar/docker-spring-micro-services)
[![Docker Hub](https://img.shields.io/docker/build/bednar/docker-spring-micro-services.svg?style=flat)](https://registry.hub.docker.com/u/bednar/docker-spring-micro-services/)
[![Docker Hub](https://img.shields.io/docker/pulls/bednar/docker-spring-micro-services.svg?style=flat)](https://registry.hub.docker.com/u/bednar/docker-spring-micro-services/)
[![Docker Hub](https://img.shields.io/docker/stars/bednar/docker-spring-micro-services.svg?style=flat)](https://registry.hub.docker.com/u/bednar/docker-spring-micro-services/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://raw.githubusercontent.com/bednar/docker-spring-micro-services/master/LICENSE)


The Docker image for developing micro services based on Spring Stream.

**Using the image, you accept the [Oracle Binary Code License Agreement](http://www.oracle.com/technetwork/java/javase/terms/license/index.html) for Java SE.**

![Infrastructure](./Infrastructure.png)

## Elastic Stack - Elasticsearch, Logstash, and Kibana
### Elasticsearch
- Indexes - [http://localhost:9200/_cat/indices](http://localhost:9200/_cat/indices)
- Status - [http://localhost:9200/_cat/health](http://localhost:9200/_cat/health)
- REST API - [http://localhost:9200/_cat/](http://localhost:9200/_cat/)

### Logstash
### Kibana
 - [http://localhost:5601/](http://localhost:5601/)

## Docker

### Build a Dockerfile and an Image
```bash
# Install the Groovy
brew install groovy

# Customise recipes versions
open versions.json

# Create the Dockerfile
groovy build.groovy

## Build the docker image
docker build -t "bednar:docker-spring-micro-services" .
```
## Run an Image
```bash
## Run the builded image in background
docker run -d -p 5601:5601 -p 9200:9200 -t bednar:docker-spring-micro-services
```
