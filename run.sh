#!/bin/bash

# Based on https://www.jenkins.io/doc/book/installing/docker/

# docker network create jenkins
# 
# docker run \
#   --name jenkins-docker \
#   --rm \
#   --detach \
#   --privileged \
#   --network jenkins \
#   --network-alias docker \
#   --env DOCKER_TLS_CERTDIR=/certs \
#   --volume jenkins-docker-certs:/certs/client \
#   --volume jenkins-data:/var/jenkins_home \
#   --publish 2376:2376 \
#   docker:dind \
#   --storage-driver overlay2



# https://octopus.com/blog/jenkins-docker-install-guide
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk11

