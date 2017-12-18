# docker-spring-micro-services
[![Docker Hub](https://img.shields.io/docker/pulls/bednar/docker-spring-micro-services.svg?style=flat)](https://registry.hub.docker.com/u/bednar/docker-spring-micro-services/) 
[![Docker Hub](https://img.shields.io/docker/stars/bednar/docker-spring-micro-services.svg?style=flat)](https://registry.hub.docker.com/u/bednar/docker-spring-micro-services/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://raw.githubusercontent.com/bednar/docker-spring-micro-services/master/LICENSE)
[![CircleCI](https://circleci.com/gh/bednar/docker-spring-micro-services.svg?style=shield&circle-token=:circle-ci-badge-token)](https://circleci.com/gh/bednar/docker-spring-micro-services) 


The Docker image for developing micro services based on Spring Stream.
___
**Using the image, you accept the [Oracle Binary Code License Agreement](http://www.oracle.com/technetwork/java/javase/terms/license/index.html) for Java SE.**
___

## Customise docker image
```bash
# Install groovy
brew install groovy

# Customise versions
open versions.json

# Create docker file
groovy build.groovy

## Build docker image (feel free to change image name - bednar:docker-spring-micro-services)
docker build -t "bednar:docker-spring-micro-services" .

## Run builded image in background
docker run -d -t bednar:docker-spring-micro-services
```
