#!/bin/bash
#################################################################################
#
# AUTHOR	    : Lebougui
# DATE 		    : 2016/12/13	
# DESCRIPTION	: Redis server deployment.
#
#################################################################################
VERSION="1.0"
MAINTAINERS="Lebougui"
TRUE="true"
FALSE="false"

VERBOSE=$FALSE
IMAGE_PREFIX="test"

DEFAULT_DEPLOYMENT_MODE="default"
MASTER_SLAVE_DEPLOYMENT_MODE="master/slave"
CLUSTER_DEPLOYMENT_MODE="cluster"
DEPLOYMENT_MODE=$DEFAULT_DEPLOYMENT_MODE

CURRENT_DIR=`dirname $0`

#set -x

# display this script help
help_docker()
{
cat << EOF
Usage : $0 -i <image name> -n <container name>

Build and start a redis container.


OPTIONS :
    -h              displays this help.
    -i              docker image to create.
    -n              docker container name to start. 
    -m              advanced deployment in master/slave mode.
    -c              advanced cluster mode deployment. 6 masters and 6 slaves will be deployed.

WARNING : [-c] and [-m] can not been used together. 

Examples :
    ./run.sh -i test-redis -n test-redis

EOF

version

}

# display this script help
help_red_hat()
{
cat << EOF
Usage : $0 -r

Install and configure redis cluster.


OPTIONS :
        -h              displays this help.
        -r              remove existing redis before new installation.
        -m              advanced deployment in master/slave mode.

Examples :
        #Default install mode
        ./run.sh 

        #Master/slave install mode 
        ./run.sh -m

EOF

version

}

# display this script version
version()
{
    echo -e "Version       : $0 $VERSION (2016/12/13) " 
    echo -e "Maintainer(s) : $MAINTAINERS \n"
}

validate_params()
{
    if [ -z "$2" ] 
    then
        echo -e "Bad $1 (given is $2)."
        help
        exit -1
    fi
}

debianlike_install()
{
    apt-get install docker.io
    service docker start

    update-rc.d docker start

    docker run hello-world
}

set_platform_name()
{
    case `uname -s` in
        Linux) PLATFORM="Linux"
        ;;

        Darwin)PLATFORM="Mac-OS"
        ;;

        *)echo "Unknown platoform".
          exit 1
    esac
}

run_container()
{
    if [ $DEPLOYMENT_MODE == $DEFAULT_DEPLOYMENT_MODE ]
    then
        docker run -d -p 6379:6379 --name $REDIS_CONTAINER_NAME $REDIS_IMG_NAME

        REDIS_CONTAINER_ID=`docker ps -a | awk '{if ($NF == "'$REDIS_CONTAINER_NAME'") print $1}'`

        if [ $PLATFORM == "Linux" ]
        then
            REDIS_CONTAINER_IP=`docker inspect -f '{{.NetworkSettings.IPAddress}}' $REDIS_CONTAINER_ID`
        else
            REDIS_CONTAINER_IP=`docker-machine ip default`
        fi
    elif [ $DEPLOYMENT_MODE == $MASTER_SLAVE_DEPLOYMENT_MODE ]
    then
        docker run -d --net=host -v $(pwd)/$CURRENT_DIR/master-slave/redis-master.conf:/usr/local/etc/redis/redis.conf --name "$REDIS_CONTAINER_NAME-master" $REDIS_IMG_NAME /usr/local/etc/redis/redis.conf

        docker run -d --net=host -v $(pwd)/$CURRENT_DIR/master-slave/redis-slave.conf:/usr/local/etc/redis/redis.conf --name "$REDIS_CONTAINER_NAME-slave" $REDIS_IMG_NAME /usr/local/etc/redis/redis.conf
    else 
        sudo gem install redis

        for entry in 7000 7001 7002 7003 7004 7005
        do
            docker run -d  --net=host -v $(pwd)/$CURRENT_DIR/cluster/$entry/redis.conf:/usr/local/etc/redis/redis.conf --name "redis-$entry" $REDIS_IMG_NAME /usr/local/etc/redis/redis.conf
        done

        chmod 755 $(pwd)/$CURRENT_DIR/cluster/redis-trib.rb
        $(pwd)/$CURRENT_DIR/cluster/redis-trib.rb create --replicas 1 127.0.0.1:7000 \
                                                                      127.0.0.1:7001 \
                                                                      127.0.0.1:7002 \
                                                                      127.0.0.1:7003 \
                                                                      127.0.0.1:7004 \
                                                                      127.0.0.1:7005

    fi

    
}

if [ -e /etc/redhat-release ]
then
    REMOVE_REDIS=$FALSE

    while getopts "hrm" param; do
        case $param in
            h) help_red_hat
               exit 0
            ;;

            r) REMOVE_REDIS=$TRUE
            ;;

            m)DEPLOYMENT_MODE=$MASTER_SLAVE_DEPLOYMENT_MODE
            ;;

            *) echo "Invalid option"
               help_red_hat
               exit 1
            ;;
        esac
    done

    echo "Executing on `cat /etc/redhat-release`..."
    sleep 3

    if [ $REMOVE_REDIS == $TRUE ]
    then
        rm -rf /usr/local/bin/redis-server
    fi

    yum install -y make gcc wget
    wget http://download.redis.io/redis-stable.tar.gz
    tar xzvf redis-stable.tar.gz

    make -C redis-stable/deps hiredis jemalloc linenoise lua geohash-int
    make -C redis-stable
    make -C redis-stable install 
    rm -rf redis-stable*

    mkdir -p /etc/redis
    cat > /etc/redis/redis.conf<<EOF
port 6379
#cluster-enabled yes
#cluster-config-file nodes.conf
#cluster-node-timeout 5000
appendonly yes
#requirepass test
maxmemory-policy noeviction
appendfilename redis-staging.aof
bind 0.0.0.0
EOF

cat > /etc/redis/redis-slave.conf<<EOF
port 6380
#cluster-enabled yes
#cluster-config-file nodes.conf
#cluster-node-timeout 5000
appendonly yes
#requirepass test
slaveof 127.0.0.1 6379
#masterauth test
bind 0.0.0.0
EOF

    cat > /etc/init.d/redis<<EOF
#!/bin/sh
#
#       /etc/rc.d/init.d/redis
#
#       Lebougui
#
# chkconfig:   2345 95 95
# description: Start redis

### BEGIN INIT INFO
# Provides:       redis
# Required-Start: $network cgconfig
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start: 2 3 4 5
# Default-Stop:  0 1 6
# Short-Description: start and stop docker
### END INIT INFO

prog="/usr/local/bin/redis-server"
pid_file="/var/run/redis.pid"
slave_pid_file="/var/run/redis-slave.pid"

start() {
    if [ ! -x \$prog ]; then
      if [ ! -e \$prog ]; then
        echo -e "redis-server \$prog not found \n" 
      else
        echo -e "You do not have permission to execute the \$prog \n"
      fi
      exit 5
    fi

    echo -e "Starting redis \n" 
    \$prog /etc/redis/redis.conf &
    echo \$! > "\$pid_file" ;
}

stop() {
    if [ -e \$pid_file ]
    then
        echo -e "Stopping redis (pid = \$(cat "\$pid_file")) \n" 
        kill -9 \$(cat "\$pid_file")
    fi

    if [ -e \$slave_pid_file ]
    then
        echo -e "Stopping redis slave (pid = \$(cat "\$slave_pid_file")) \n" 
        kill -9 \$(cat "\$slave_pid_file")
    fi

    rm -rf \$pid_file \$slave_pid_file
}

restart() {
    stop
    start
}

masterslave() {
    if [ ! -x \$prog ]; then
      if [ ! -e \$prog ]; then
        echo -e "redis-server \$prog not found \n" 
      else
        echo -e "You do not have permission to execute the \$prog \n"
      fi
      exit 5
    fi

    echo -e "Starting redis master \n" 
    \$prog /etc/redis/redis.conf &
    echo \$! > "\$pid_file" ;

    echo -e "Starting redis slave \n" 
    \$prog /etc/redis/redis-slave.conf &
    echo \$! > "\$slave_pid_file" ;
}

status() {
    if [ -e \$pid_file ]
    then
        echo -e "redis is running (pid = \$(cat "\$pid_file")) \n" 
    fi

    if [ -e \$slave_pid_file ]
    then
        echo -e "redis slave is running (pid = \$(cat "\$slave_pid_file")) \n" 
    fi
}

case "\$1" in
    start)
        \$1
        ;;
    stop)
        \$1
        ;;
    restart)
        \$1
        ;;
    status)
        \$1
        ;;
    masterslave)
        \$1
        ;;
    *)
        echo -e "Usage: \$0 {start|stop|restart|status|masterslave} \n"
        exit 2
        ;;

esac

exit \$?
EOF
  
    chmod 755 /etc/init.d/redis

    if [DEPLOYMENT_MODE=$MASTER_SLAVE_DEPLOYMENT_MODE

    /etc/init.d/redis start

    #Auto start redis
    chkconfig redis on

    SERVER_IP=` ifconfig -a eth0 |awk '{if ($1 == "inet") {split($2, t, ":"); print t[2]}}' `
    iptables -I INPUT 5 -i eth0 -p tcp --dport 6379 -m state --state NEW,ESTABLISHED -j ACCEPT
    service iptables save

    echo "To connect on redis server use these parameters : host = $SERVER_IP - port = 6379"
else
    REDIS_IMG_NAME="test-redis"
    REDIS_CONTAINER_NAME="test-redis"

    set_platform_name

    while getopts "hi:n:mc" param; do
        case $param in
            h) help_docker
               exit 0
            ;;

            i)REDIS_IMG_NAME="$OPTARG"
            ;;

            n)REDIS_CONTAINER_NAME="$OPTARG"
            ;;

            m)DEPLOYMENT_MODE=$MASTER_SLAVE_DEPLOYMENT_MODE
            ;;

            c)DEPLOYMENT_MODE=$CLUSTER_DEPLOYMENT_MODE
            ;;

            *) echo "Invalid option"
               help_docker
               exit 1
            ;;
        esac
    done

    validate_params "redis image name is " $REDIS_IMG_NAME
    validate_params "redis container name is " $REDIS_CONTAINER_NAME

    docker -v 
    if [ "$?" != "0" ]
    then
        if [ -e "/etc/os-release" ]
        then
            NAME=`cat /etc/os-release | grep "^NAME=" | awk 'BEGIN{FS="="}{gsub("\"", "", $2); print $2}'`
            VERSION=`cat /etc/os-release | grep "^VERSION=" | awk 'BEGIN{FS="="}{gsub("\"", "", $2); print $2}'`

            echo "Installing on $NAME $VERSION..."
            sleep 3

            debianlike_install
        else
            echo "Please install docker first"
            exit 1
        fi
    fi


    echo "Stopping all running containers...".
    docker stop `docker ps -a -q`
    docker rm `docker ps -a -q`

    echo "Building redis container...".
    docker build -t $REDIS_IMG_NAME $CURRENT_DIR/.             

    echo "Starting redis container..."
    run_container

    if [ $DEPLOYMENT_MODE == $DEFAULT_DEPLOYMENT_MODE ]
    then
        echo "To connect on redis server use these parameters : host = $REDIS_CONTAINER_IP or 127.0.0.1 - port = 6379"
    elif [ $DEPLOYMENT_MODE == $MASTER_SLAVE_DEPLOYMENT_MODE ]
    then
        echo "Master/slave enabled."
        echo "Master host = 127.0.0.1 - port = 6379"
        echo "Slave host = 127.0.0.1 - port = 6380"
    else 
        echo "Cluster mode enabled."
        echo "host 1 = 127.0.0.1 - port = 7000"
        echo "host 2 = 127.0.0.1 - port = 7001"
        echo "host 3 = 127.0.0.1 - port = 7002"
        echo "host 4 = 127.0.0.1 - port = 7003"
        echo "host 5 = 127.0.0.1 - port = 7004"
        echo "host 6 = 127.0.0.1 - port = 7005"
    fi

fi

exit 0

