#! /bin/bash -e

apt-get update
apt-get install -y supervisor vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat software-properties-common maven
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer oracle-java7-set-default

echo "Installing Druid."
if [ ! -d "druid-services" ]; then

wget --quiet http://static.druid.io/artifacts/releases/druid-services-0.6.160-bin.tar.gz && \
  tar -zxf druid-services-*.gz && \
  mv druid-services-0.6.160 druid-services &&\
  mv druid-services/config druid-services/config.orig &&\
  cp -r /vagrant/config druid-services/config &&\
  chown -R vagrant:vagrant druid-services 

fi

echo "Installing Druid plugins."
if [ ! -d "druid-src" ]; then
    git clone https://github.com/metamx/druid.git druid-src
    cd druid-src
    git checkout tags/druid-0.6.160
    mvn install -DskipTests
    cd -
fi

echo "Installing Zookeeper."

if [ ! -d "zookeeper" ]; then

wget --quiet http://mirrors.ibiblio.org/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz && \
  tar xzf zookeeper-*.tar.gz && \
  mv zookeeper-3.4.6 zookeeper && \
  cp zookeeper/conf/zoo_sample.cfg zookeeper/conf/zoo.cfg &&\
  chown -R vagrant:vagrant zookeeper
fi

DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

DB_PASSWORD=password

if mysqladmin -u root password $DB_PASSWORD 2>&1; then
  echo "Intial db root password is set now."
else
  echo "Existing db. root password is not changed."
fi

cat <<EOF | mysql -u root --password=$DB_PASSWORD
create database if not exists druid default charset utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON druid.* TO 'druid'@'localhost' IDENTIFIED BY 'diurd';
FLUSH PRIVILEGES;
EOF

echo "Configure services."
mkdir -p /var/log/{zookeeper,druid} && \
chown -R vagrant:vagrant /var/log/{zookeeper,druid}
service supervisor restart
cp /vagrant/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
supervisorctl reload
