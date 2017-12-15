# docker-spring-micro-services
[![CircleCI](https://circleci.com/gh/bednar/docker-spring-micro-services.svg?style=shield&circle-token=:circle-ci-badge-token)](https://circleci.com/gh/bednar/docker-spring-micro-services) 

The Docker image for developing micro services based on Spring Stream.

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
