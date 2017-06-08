REDIS cluster configuration
===========================

Introduction
-------------

The goal of these tools is to install and configure a redis server.
On Red Hat like platforms  (Red Hat, Centos,...) the server will be installed directly.

On Debian like platforms (Debian, Ubuntu,...), Mac Os and Windows server will be installed into a docker container.
In this case please make sure that docker daemon is running before running the script.
Visit https://docs.docker.com/engine/installation/ in order to install docker on your platform.

On all platforms the same script will be used to install redis server on a centos system.

For a given platform refer to the usage and settings sections.

#1. Usage on Debian like systems, Mac OS and Windows
Execute the run.sh script to install and configure redis server.

```

Usage : ./run.sh -i <image name> -n <container name>

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

Version       : ./run.sh 1.0 (2016/12/13) 
Maintainer(s) : Lebougui


```

In simple mode when redis is available you will have these logs 

```

To connect on redis server use these parameters : host = 172.17.0.142 or 127.0.0.1 - port = 6379


```


In advanced mode (master/slave) when redis is available you will have these logs 

```

Master/slave enabled.
Master host = 127.0.0.1 - port = 6379
Slave host = 127.0.0.1 - port = 6380

```

You can verify that master and slave are connected like this :

```

# docker ps -a            
CONTAINER ID        IMAGE                  COMMAND                CREATED             STATUS              PORTS               NAMES
842c7f7c9b97        test-redis:latest   "docker-entrypoint.s   26 seconds ago      Up 25 seconds                           test-redis-slave    
3c7de47547a4        test-redis:latest   "docker-entrypoint.s   26 seconds ago      Up 25 seconds                           test-redis-master


# (Check that master is ready)
# docker logs 3c7de47547a4
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 3.2.5 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 1
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

1:M 13 Dec 13:27:48.679 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 13 Dec 13:27:48.679 # Server started, Redis version 3.2.5
1:M 13 Dec 13:27:48.680 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 13 Dec 13:27:48.680 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
1:M 13 Dec 13:27:48.680 * The server is now ready to accept connections on port 6379
1:M 13 Dec 13:27:49.096 * Slave 127.0.0.1:6380 asks for synchronization
1:M 13 Dec 13:27:49.096 * Full resync requested by slave 127.0.0.1:6380
1:M 13 Dec 13:27:49.096 * Starting BGSAVE for SYNC with target: disk
1:M 13 Dec 13:27:49.097 * Background saving started by pid 15
15:C 13 Dec 13:27:49.155 * DB saved on disk
15:C 13 Dec 13:27:49.155 * RDB: 6 MB of memory used by copy-on-write
1:M 13 Dec 13:27:49.181 * Background saving terminated with success
1:M 13 Dec 13:27:49.182 * Synchronization with slave 127.0.0.1:6380 succeeded


# (Check that slave has correctly connected to master )
# docker logs 842c7f7c9b97
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 3.2.5 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6380
 |    `-._   `._    /     _.-'    |     PID: 1
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

1:S 13 Dec 13:27:49.095 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:S 13 Dec 13:27:49.095 # Server started, Redis version 3.2.5
1:S 13 Dec 13:27:49.095 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:S 13 Dec 13:27:49.095 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
1:S 13 Dec 13:27:49.095 * The server is now ready to accept connections on port 6380
1:S 13 Dec 13:27:49.095 * Connecting to MASTER 127.0.0.1:6379
1:S 13 Dec 13:27:49.095 * MASTER <-> SLAVE sync started
1:S 13 Dec 13:27:49.095 * Non blocking connect for SYNC fired the event.
1:S 13 Dec 13:27:49.095 * Master replied to PING, replication can continue...
1:S 13 Dec 13:27:49.095 * Partial resynchronization not possible (no cached master)
1:S 13 Dec 13:27:49.103 * Full resync from master: 9457c62fe5b7c4ddc41c2023bed1132a0fc3a997:1
1:S 13 Dec 13:27:49.181 * MASTER <-> SLAVE sync: receiving 76 bytes from master
1:S 13 Dec 13:27:49.182 * MASTER <-> SLAVE sync: Flushing old data
1:S 13 Dec 13:27:49.182 * MASTER <-> SLAVE sync: Loading DB in memory
1:S 13 Dec 13:27:49.182 * MASTER <-> SLAVE sync: Finished with success
1:S 13 Dec 13:27:49.185 * Background append only file rewriting started by pid 15
1:S 13 Dec 13:27:49.225 * AOF rewrite child asks to stop sending diffs.
15:C 13 Dec 13:27:49.226 * Parent agreed to stop sending diffs. Finalizing AOF...
15:C 13 Dec 13:27:49.226 * Concatenating 0.00 MB of AOF diff received from parent.
15:C 13 Dec 13:27:49.226 * SYNC append only file rewrite performed
15:C 13 Dec 13:27:49.226 * AOF rewrite: 6 MB of memory used by copy-on-write
1:S 13 Dec 13:27:49.295 * Background AOF rewrite terminated with success
1:S 13 Dec 13:27:49.295 * Residual parent diff successfully flushed to the rewritten AOF (0.00 MB)
1:S 13 Dec 13:27:49.295 * Background AOF rewrite finished successfully


```


In advanced cluster mode here are the logs during the installation (by default 3 masters and 3 slaves will be automatically configured): 

```

>>> Creating cluster
>>> Performing hash slots allocation on 6 nodes...
Using 3 masters:
127.0.0.1:7000
127.0.0.1:7001
127.0.0.1:7002
Adding replica 127.0.0.1:7003 to 127.0.0.1:7000
Adding replica 127.0.0.1:7004 to 127.0.0.1:7001
Adding replica 127.0.0.1:7005 to 127.0.0.1:7002
M: 776640dc09ef77cb8b536474c11530f806a08250 127.0.0.1:7000
   slots:0-5460 (5461 slots) master
M: 7120a4dadab4c39202ea92cd7e26fced18b3e903 127.0.0.1:7001
   slots:5461-10922 (5462 slots) master
M: caf8764bd61992ef7650cf883e02a451cd16c186 127.0.0.1:7002
   slots:10923-16383 (5461 slots) master
S: f19bc5f47609cfb3a4b7ab7bceb3bb7583b8a458 127.0.0.1:7003
   replicates 776640dc09ef77cb8b536474c11530f806a08250
S: c3c8b85eb6dc5fd9a2cd98030a3426dc88bff3ae 127.0.0.1:7004
   replicates 7120a4dadab4c39202ea92cd7e26fced18b3e903
S: 081d0776eb8c1f114fbcee043e11079e3f65d2c4 127.0.0.1:7005
   replicates caf8764bd61992ef7650cf883e02a451cd16c186
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join...
>>> Performing Cluster Check (using node 127.0.0.1:7000)
M: 776640dc09ef77cb8b536474c11530f806a08250 127.0.0.1:7000
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
M: 7120a4dadab4c39202ea92cd7e26fced18b3e903 127.0.0.1:7001
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
S: 081d0776eb8c1f114fbcee043e11079e3f65d2c4 127.0.0.1:7005
   slots: (0 slots) slave
   replicates caf8764bd61992ef7650cf883e02a451cd16c186
S: c3c8b85eb6dc5fd9a2cd98030a3426dc88bff3ae 127.0.0.1:7004
   slots: (0 slots) slave
   replicates 7120a4dadab4c39202ea92cd7e26fced18b3e903
S: f19bc5f47609cfb3a4b7ab7bceb3bb7583b8a458 127.0.0.1:7003
   slots: (0 slots) slave
   replicates 776640dc09ef77cb8b536474c11530f806a08250
M: caf8764bd61992ef7650cf883e02a451cd16c186 127.0.0.1:7002
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
Cluster mode enabled.

host = 127.0.0.1 - port = 7000
host = 127.0.0.1 - port = 7001
host = 127.0.0.1 - port = 7002
host = 127.0.0.1 - port = 7003
host = 127.0.0.1 - port = 7004
host = 127.0.0.1 - port = 7005

#(To verify that the all cluster nodes are un and running user this command)
# docker ps -a 
CONTAINER ID        IMAGE                  COMMAND                CREATED             STATUS              PORTS               NAMES
23f9085965bf        test-redis:latest   "docker-entrypoint.s   4 minutes ago       Up 4 minutes                            redis-7005          
28e8ba6deb71        test-redis:latest   "docker-entrypoint.s   4 minutes ago       Up 4 minutes                            redis-7004          
483339ff8585        test-redis:latest   "docker-entrypoint.s   4 minutes ago       Up 4 minutes                            redis-7003          
e59d74eaa203        test-redis:latest   "docker-entrypoint.s   4 minutes ago       Up 4 minutes                            redis-7002          
998d356b4ca5        test-redis:latest   "docker-entrypoint.s   4 minutes ago       Up 4 minutes                            redis-7001          
b9c9caf5415c        test-redis:latest   "docker-entrypoint.s   4 minutes ago       Up 4 minutes                            redis-7000

```


#2. Usage on Red Hat like systems
Execute the run.sh script to install and configure redis server. 

```

Usage : ./run.sh -r

Install and configure redis cluster.


OPTIONS :
        -h              displays this help.
        -r              remove existing redis before new installation.
        -m              advanced deployment in master/slave mode.

Examples :
        #Default install mode
        ./run.sh 

        #Remove existing redis and install new one 
        ./run.sh -r

```

In this mode we cannot perform by default a master/slave or cluster mode installation automatically.
The configuration is done but only defalt mode can be configured to started automatically.
To start redis in master/slave or cluster mode call directly "/etc/init.d/redis" at the end of the installation.

```
# /etc/init.d/redis 
Usage: /etc/init.d/redis {start|stop|restart|masterslave}

# /etc/init.d/redis status
redis is running (pid = 19246)

# /etc/init.d/redis stop
Stopping redis (pid = 19246)

# /etc/init.d/redis masterslave
Starting redis master 

Starting redis slave 

                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 3.2.6 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 19220
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

19220:M 13 Dec 18:17:29.103 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
19220:M 13 Dec 18:17:29.104 # Server started, Redis version 3.2.6
19220:M 13 Dec 18:17:29.104 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
19220:M 13 Dec 18:17:29.104 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
19220:M 13 Dec 18:17:29.104 * The server is now ready to accept connections on port 6379
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 3.2.6 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6380
 |    `-._   `._    /     _.-'    |     PID: 19221
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

19221:S 13 Dec 18:17:29.121 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
19221:S 13 Dec 18:17:29.121 # Server started, Redis version 3.2.6
19221:S 13 Dec 18:17:29.121 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
19221:S 13 Dec 18:17:29.121 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
19221:S 13 Dec 18:17:29.121 * The server is now ready to accept connections on port 6380
19221:S 13 Dec 18:17:29.121 * Connecting to MASTER 127.0.0.1:6379
19221:S 13 Dec 18:17:29.121 * MASTER <-> SLAVE sync started
19221:S 13 Dec 18:17:29.121 * Non blocking connect for SYNC fired the event.
19221:S 13 Dec 18:17:29.142 * Master replied to PING, replication can continue...
19221:S 13 Dec 18:17:29.143 * Partial resynchronization not possible (no cached master)
19220:M 13 Dec 18:17:29.143 * Slave 127.0.0.1:6380 asks for synchronization
19220:M 13 Dec 18:17:29.143 * Full resync requested by slave 127.0.0.1:6380
19220:M 13 Dec 18:17:29.143 * Starting BGSAVE for SYNC with target: disk
19220:M 13 Dec 18:17:29.151 * Background saving started by pid 19226
19221:S 13 Dec 18:17:29.152 * Full resync from master: dd15df6f1bb11eceb0c9af090f216e55b2f44c6f:1
19226:C 13 Dec 18:17:29.197 * DB saved on disk
19226:C 13 Dec 18:17:29.197 * RDB: 6 MB of memory used by copy-on-write
19220:M 13 Dec 18:17:29.204 * Background saving terminated with success
19220:M 13 Dec 18:17:29.204 * Synchronization with slave 127.0.0.1:6380 succeeded
19221:S 13 Dec 18:17:29.204 * MASTER <-> SLAVE sync: receiving 76 bytes from master
19221:S 13 Dec 18:17:29.204 * MASTER <-> SLAVE sync: Flushing old data
19221:S 13 Dec 18:17:29.204 * MASTER <-> SLAVE sync: Loading DB in memory
19221:S 13 Dec 18:17:29.205 * MASTER <-> SLAVE sync: Finished with success
19221:S 13 Dec 18:17:29.205 * Background append only file rewriting started by pid 19227
19221:S 13 Dec 18:17:29.255 * AOF rewrite child asks to stop sending diffs.
19227:C 13 Dec 18:17:29.255 * Parent agreed to stop sending diffs. Finalizing AOF...
19227:C 13 Dec 18:17:29.255 * Concatenating 0.00 MB of AOF diff received from parent.
19227:C 13 Dec 18:17:29.255 * SYNC append only file rewrite performed
19227:C 13 Dec 18:17:29.256 * AOF rewrite: 6 MB of memory used by copy-on-write
19221:S 13 Dec 18:17:29.321 * Background AOF rewrite terminated with success
19221:S 13 Dec 18:17:29.321 * Residual parent diff successfully flushed to the rewritten AOF (0.00 MB)
19221:S 13 Dec 18:17:29.321 * Background AOF rewrite finished successfully

#

# /etc/init.d/redis status
redis is running (pid = 19220) 
redis slave is running (pid = 19221) 

```

## Openstack additional configuration
On Openstack environment redis port(s) mus be opened in security groups in order to be able to connect to redis server.
Default redis port is 6379. Use the port according to the one set in redis.conf file.




