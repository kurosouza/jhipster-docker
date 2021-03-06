# DOCKER-VERSION 1.8.2
FROM       ubuntu:trusty
MAINTAINER Julien Dubois <julien.dubois@gmail.com>

ENV JAVA_VERSION 8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ENV MAVEN_VERSION 3.3.3
ENV MAVEN_HOME /usr/share/maven
ENV PATH "$PATH:$MAVEN_HOME/bin"

ENV GRADLE_VERSION 2.9
ENV GRADLE_HOME /usr/share/gradle
ENV PATH "$PATH:$GRADLE_HOME/bin"

# install utilities
RUN apt-get -y install vim git sudo zip bzip2 fontconfig curl

# install gradle
RUN curl -fsSL https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip | unzip - -d /usr/share \
  && mv /usr/share/gradle-$GRADLE_VERSION /usr/share/gradle \
  && ln -s /usr/share/gradle/bin/gradle /usr/bin/gradle

# install maven
# RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
#     && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
#     && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# install java8
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VERSION}-installer oracle-java${JAVA_VERSION}-set-default

# install node.js
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
RUN apt-get install -y nodejs python g++ build-essential

# install yeoman bower grunt gulp
RUN npm install -g yo bower grunt-cli gulp

# install JHipster
ENV JHIPSTER_VERSION 2.24.0
RUN npm install -g generator-jhipster@${JHIPSTER_VERSION}

# install jhipster-uml
RUN npm install -g jhipster-uml

# configure the "jhipster" user
RUN groupadd jhipster && useradd jhipster -s /bin/bash -m -g jhipster -G jhipster && adduser jhipster sudo
RUN echo 'jhipster:jhipster' |chpasswd
RUN mkdir -p /home/jhipster/app
ADD banner.txt /home/jhipster/banner.txt
RUN cd /home && chown -R jhipster:jhipster /home/jhipster

# clean
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/oracle-jdk${JAVA_VERSION}-installer

# expose the working directory, the Tomcat port, the BrowserSync ports
VOLUME ["/home/jhipster/app"]
EXPOSE 8080 3000 3001
CMD    ["tail", "-f", "/home/jhipster/banner.txt"]
