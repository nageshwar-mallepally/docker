FROM  ubuntu:16.04
USER root
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# Install java8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;



# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME


# Install wget
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN  apt-get update \
  && apt-get install -y maven \
  && rm -rf /var/lib/apt/lists/*

# Install git
RUN  apt-get update \
  && apt-get install -y git \
  && rm -rf /var/lib/apt/lists/*


# Install tomcat8
RUN mkdir -p 	/opt/tomcat/

WORKDIR /opt/tomcat
ADD http://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz .
RUN tar xvfz apache*.tar.gz -C /opt/.
RUN rm -r /opt/tomcat/*
RUN mv /opt/apache-tomcat-8.5.50/* /opt/tomcat/.
RUN rm -r /opt/apache-tomcat-8.5.50
#WORKDIR /opt/tomcat/webapps
EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc

RUN apt-get -y update
RUN apt-get install -y gnupg
RUN mkdir ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf	
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8


# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-get update && apt-get install -y gnupg2
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.4
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y software-properties-common postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.4`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER cassinisys WITH SUPERUSER PASSWORD 'cassinisys';" &&\
    createdb -O cassinisys cassiniapps

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.4/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.4/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.4/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
USER root
RUN chown root:root -R /etc/init.d/postgresql /usr/lib/postgresql/9.4 /var/lib/postgresql/9.4 /etc/postgresql/9.4/main
RUN chmod 777 -R /etc/init.d/postgresql /usr/lib/postgresql/9.4 /var/lib/postgresql/9.4 /etc/postgresql/9.4/main


# Install Nodejs bower
RUN apt-get update
RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get -y install nodejs
RUN npm install
RUN node -v
RUN npm -v
RUN npm config set prefix /usr/local
RUN npm install -g bower-update
RUN npm install bower -g
RUN echo '{ "allow_root": true }' > /root/.bowerrc

# Install Groovy
RUN apt-get install -y groovy

# Create one folder 
RUN mkdir -p /root/cassiniapps && \
    mkdir -p /root/fsroot/cassini
	

# ADD VOLUMEs
WORKDIR /
#VOLUME  ["/root/cassiniapps", "/opt/tomcat"]

# Clone and build root and platform

#RUN git clone https://nagesh028.m:Cassini%23123@git.assembla.com/cassinisys.apps.git /root/cassiniapps

#RUN mvn -f /root/cassiniapps/cassini.root/pom.xml install 

#RUN mvn -f /root/cassiniapps/cassini.platform/pom.xml clean generate-sources install -DskipTests

#Build Cassini.IM			

#WORKDIR /root/cassiniapps/cassini.im/src/main/webapp
#RUN bower update	
#WORKDIR /
#RUN mvn -f /root/cassiniapps/cassini.im/pom.xml clean generate-sources install -DskipTests
#RUN cp -r /root/cassiniapps/cassini.im/target/cassini.im /opt/tomcat/webapp

#WORKDIR /root/cassiniapps/cassini.plm/src/main/webapp
#RUN bower update	
#WORKDIR /
#RUN mvn -f /root/cassiniapps/cassini.plm/pom.xml clean generate-sources install -DskipTests

#WORKDIR /root/cassiniapps/cassini.drdo/src/main/webapp
#RUN bower update	
#WORKDIR /
#RUN mvn -f /root/cassiniapps/cassini.drdo/pom.xml clean generate-sources install -DskipTests

#WORKDIR /root/cassiniapps/cassini.is/src/main/webapp
#RUN bower update	
#WORKDIR /
#RUN mvn -f /root/cassiniapps/cassini.is/pom.xml clean generate-sources install -DskipTests


VOLUME  ["/opt/tomcat", "/root/.m2"]


