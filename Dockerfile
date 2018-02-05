FROM ubuntu:16.04

MAINTAINER Jakub Bednar <https://github.com/bednar>

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update --fix-missing

# install wget, unzip, sudo, curl, ...
RUN apt-get install -y wget unzip sudo apt-transport-https multitail curl joe jq

# add Elastic.co repository
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
RUN apt-get update

# Recipes

# Java JDK [1.8.0_161]
# set shell variables for java installation
ENV java_version 1.8.0_161
ENV filename jdk-8u161-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/$filename
# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -nv -O /tmp/$filename $downloadlink 
# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH
# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# Apache Maven [3.5.2]
# download
RUN wget -nv -O /tmp/apache-maven-3.5.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz
# verify checksum
RUN echo "948110de4aab290033c23bf4894f7d9a /tmp/apache-maven-3.5.2.tar.gz" | md5sum -c
# install maven
RUN tar xzf /tmp/apache-maven-3.5.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.5.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.5.2.tar.gz
ENV MAVEN_HOME /opt/maven

# Gradle Build Tool [4.4.1]
# download
RUN wget -nv -O /tmp/gradle-4.4.1-bin.zip https://services.gradle.org/distributions/gradle-4.4.1-bin.zip
# verify checksum
RUN echo "e7cf7d1853dfc30c1c44f571d3919eeeedef002823b66b6a988d27e919686389 /tmp/gradle-4.4.1-bin.zip" | sha256sum -c
# install gradle
RUN unzip /tmp/gradle-4.4.1-bin.zip -d /opt/
RUN ln -s /opt/gradle-4.4.1 /opt/gradle
RUN ln -s /opt/gradle/bin/gradle /usr/local/bin
RUN rm -f /tmp/gradle-4.4.1-bin.zip
ENV GRADLE_HOME /opt/gradle

# Elasticsearch [5.6.5]
# install from repository
RUN apt-get install -y elasticsearch=5.6.5
ADD ./recipes/config/elasticsearch-jvm.options /etc/elasticsearch/jvm.options
ADD ./recipes/config/elasticsearch-provisioning /usr/share/elasticsearch/bin/elasticsearch-provisioning
RUN chmod +x /usr/share/elasticsearch/bin/elasticsearch-provisioning
ADD ./recipes/config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
RUN chown -R elasticsearch:elasticsearch /etc/elasticsearch/
# add system services
RUN sudo update-rc.d elasticsearch defaults 95 10

# Kibana [5.6.5]
# install from repository
RUN apt-get install -y kibana=5.6.5
# add system services
RUN sudo update-rc.d kibana defaults 95 10
ADD ./recipes/config/kibana.yml /etc/kibana/kibana.yml
ADD ./recipes/config/kibana-provisioning /usr/share/kibana/bin/kibana-provisioning
RUN chmod +x /usr/share/kibana/bin/kibana-provisioning

# Logstash [5.6.5]
# install from repository
RUN apt-get install -y logstash
# generate SysV script
RUN /usr/share/logstash/bin/system-install /etc/logstash/startup.options sysv
ADD ./recipes/config/logstash-pipeline.conf /etc/logstash/conf.d/pipeline.conf
RUN chown -R logstash:logstash /etc/logstash/conf.d/
# add ty system services
RUN sudo update-rc.d logstash defaults 95 10

# Apache ZooKeeper [3.4.6]
# add user and make dirs
RUN useradd zookeeper
RUN mkdir -p /tmp/zookeeper /var/log/zookeeper/
RUN chown zookeeper:zookeeper /tmp/zookeeper /var/log/zookeeper/
# install ZooKeeper
RUN wget -nv -O /tmp/zookeeper-3.4.6.tar.gz https://archive.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
RUN echo "971c379ba65714fd25dc5fe8f14e9ad1 /tmp/zookeeper-3.4.6.tar.gz" | md5sum -c
RUN tar -xzf /tmp/zookeeper-3.4.6.tar.gz -C /opt/
RUN ln -s /opt/zookeeper-3.4.6 /opt/zookeeper
RUN mv /opt/zookeeper-3.4.6/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
ADD ./recipes/config/zookeeper-init /etc/init.d/zookeeper
RUN chmod +x /etc/init.d/zookeeper
RUN sudo update-rc.d zookeeper defaults 95 10

# Apache Kafka [0.11.0.0]
# add user and make dirs
RUN useradd kafka
RUN mkdir -p /tmp/kafka /var/log/kafka/ /var/run/kafka/
RUN chown kafka:kafka /tmp/kafka /var/log/kafka/ /var/run/kafka/
# install Kafka
RUN wget -nv -O /tmp/kafka-0.11.0.0.tgz https://archive.apache.org/dist/kafka/0.11.0.0/kafka_2.12-0.11.0.0.tgz
RUN echo "a408f2eea282bcfa8a25ba20eb1ad49b /tmp/kafka-0.11.0.0.tgz" | md5sum -c
RUN tar -xzf /tmp/kafka-0.11.0.0.tgz -C /opt/
RUN ln -s /opt/kafka_2.12-0.11.0.0 /opt/kafka
ADD ./recipes/config/kafka-init /etc/init.d/kafka
RUN chown -R kafka:kafka /opt/kafka/
RUN chmod +x /etc/init.d/kafka
RUN sudo update-rc.d kafka defaults 95 10

# Couchbase Stack [4.6.4]
ENV package_name couchbase-server-enterprise_4.6.4-ubuntu14.04_amd64.deb
# download server
RUN wget -nv -O /tmp/$package_name http://packages.couchbase.com/releases/4.6.4/$package_name
# install server
RUN dpkg -i /tmp/$package_name
# provisioning
ADD ./recipes/config/couchbase-provisioning /opt/couchbase/bin/couchbase-provisioning
RUN chmod +x /opt/couchbase/bin/couchbase-provisioning



# remove download archive files
RUN apt-get clean

# expose ports
EXPOSE 9200 9300 5601 5044 2181 2888 3888 8091 8092 8093 8094 11207 11210 11211 18091 18092 18093 18094

# Create Log files
ADD startup.sh /opt/startup.sh
ADD startup.options /opt/startup.options
RUN /opt/startup.sh  --createLogFiles

# Start services & show logs
CMD ["sh", "-c", "/opt/startup.sh --startServices --provisioning --multitail"]