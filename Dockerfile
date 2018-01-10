# Maven with Java
FROM openjdk:8u121-jdk-alpine
#FROM maven:3.2.5-jdk-8-alpine

MAINTAINER ClckLabs <info@clcklabs.com>

# Install necessary tools

RUN apk update
RUN apk add --no-cache curl tar bash

RUN apk add apache-ant
RUN apk add python
RUN apk add py-pip
RUN pip install --upgrade pip
RUN pip install awscli
RUN curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
RUN chmod +x /usr/local/bin/ecs-cli

# MAVEN RELATED 

ARG MAVEN_VERSION=3.2.5
ARG USER_HOME_DIR="/root"
#ARG SHA=3c984a8bab93040531b53c68dea84968af09a07e1ee1a8efa711f266a8390a31
ARG SHA=8c190264bdf591ff9f1268dc0ad940a2726f9e958e367716a09b8aaa7e74a755
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN echo "Downloading:  ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz "
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

RUN chmod +x /usr/local/bin/mvn-entrypoint.sh

VOLUME "$USER_HOME_DIR/.m2"

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
