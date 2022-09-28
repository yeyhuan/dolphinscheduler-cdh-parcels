#!/bin/sh
set -x

export DS_HOME=/opt/cloudera/parcels/DS/lib/dolphinscheduler
CMD=$1

locateJava() {
  echo
   # export JAVA_HOME=/usr/java/latest
    echo "Changing Java Home to: $JAVA_HOME"
  export JAVA="$JAVA_HOME/bin/java"
  echo "Changing Java to: $JAVA"
    echo
}

config() {
   source $CONF_DIR/ds-conf.properties
   echo "dbhost: $dbhost"
   echo "dbname: $dbname"
   echo "username: $username"
   echo "password: $password"
   echo "zookeeper_server: $zookeeper_server"
   echo "masters: $masters"
   echo "workers: $workers"
   echo "alertServer: $alertServer"
   echo "apiServers: $apiServers"
   echo "pythonGatewayServers: $pythonGatewayServers"
   echo "install_path: $install_path"
   echo "api_server_port: $api_server_port"
   echo "ips: $ips"
   sed -i  "s#spring.datasource.url.*#spring.datasource.url=\"jdbc:mysql://$dbhost/$dbname?characterEncoding=UTF-8\&allowMultiQueries=true\"#g" $DS_HOME/conf/application-mysql.properties
   sed -i  "s#spring.datasource.username.*#spring.datasource.username=\"$username\"#g" $DS_HOME/conf/application-mysql.properties
   sed -i  "s#spring.datasource.password.*#spring.datasource.password=\"$password\"#g" $DS_HOME/conf/application-mysql.properties
   sed -i  "s#DATABASE_TYPE.*#DATABASE_TYPE=\"mysql\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#SPRING_DATASOURCE_URL.*#SPRING_DATASOURCE_URL=\"jdbc:mysql://$dbhost/$dbname?characterEncoding=UTF-8\&allowMultiQueries=true\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#SPRING_DATASOURCE_USERNAME.*#SPRING_DATASOURCE_USERNAME=\"$username\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#SPRING_DATASOURCE_PASSWORD.*#SPRING_DATASOURCE_PASSWORD=\"$password\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#registryServers.*#registryServers=\"$zookeeper_server\"#g" $DS_HOME/conf/config/install_config.conf
   
   sed -i  "s#ips.*#ips=\"$ips\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#masters.*#masters=\"$masters\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#workers.*#workers=\"$workers\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#alertServer.*#alertServer=\"$alertServer\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#apiServers.*#apiServers=\"$apiServers\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#pythonGatewayServers.*#pythonGatewayServers=\"$pythonGatewayServers\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#installPath=.*#installPath=\"$install_path\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#dataBasedirPath.*#dataBasedirPath=\"$install_path\"#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#data.basedir.path.*#data.basedir.path=$install_path#g" $DS_HOME/conf/common.properties
   sed -i  "s#apiServerPort.*#apiServerPort=$api_server_port#g" $DS_HOME/conf/config/install_config.conf
   sed -i  "s#server.port.*#server.port=$api_server_port#g" $DS_HOME/conf/application-api.properties

   sed -i  "s#resourceStorageType.*#resourceStorageType=\"HDFS\"#g" $DS_HOME/conf/application-api.properties
}

init() {
   echo "init"
   config
   locateJava
   #sh $DS_HOME/script/scp-hosts.sh
   if [ ! -d $install_path ];then
    sudo mkdir -p $install_path
   fi
   \cp -rf $DS_HOME/* $install_path
}
 
start() {
	echo "Running DS"
   sh $install_path/bin/dolphinscheduler-daemon-cdh.sh stop $server_name;
   exec sh $install_path/bin/dolphinscheduler-daemon-cdh.sh start $server_name;
}
 
stop() {
    echo "stop DS"
   sh $install_path/bin/dolphinscheduler-daemon-cdh.sh stop $server_name;
}
 
 
init

case "$1" in
    start)
        start
        ;;
        stop)
                stop
                ;;
    restart)
                stop
        start
                ;;
    *)
        echo "Usage DS {start|stop|restart}"
        exit 2
        ;;
esac
