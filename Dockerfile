FROM ubuntu:16.04

MAINTAINER Jakub Bednar <https://github.com/bednar>

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update --fix-missing

# install wget
RUN apt-get install -y wget

# Recipes

# Apache Maven [3.5.2]
# download
RUN wget -O /tmp/apache-maven-3.5.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz
# verify checksum
RUN echo "948110de4aab290033c23bf4894f7d9a /tmp/apache-maven-3.5.2.tar.gz" | md5sum -c
# install maven
RUN tar xzf /tmp/apache-maven-3.5.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.5.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.5.2.tar.gz
ENV MAVEN_HOME /opt/maven

# Java JDK [1.8.0_151]
# set shell variables for java installation
ENV java_version 1.8.0_151
ENV filename jdk-8u151-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/$filename
# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 
# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH
# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000



# remove download archive files
RUN apt-get clean

EXPOSE 6379