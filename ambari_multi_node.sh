#!/bin/bash
if [[ -z $(docker network inspect --format "{{.Name}}" hdp_bridge)  ]]; then
  echo "creating hdp_bridge network"
  docker network create --driver=bridge --subnet=172.18.0.0/16 --ip-range=172.18.0.1/10 hdp_bridge
fi

#Start the Namenode/Ambari Server 
echo "Starting Namenode/Ambari Server..."
docker run --network=hdp_bridge --ip=172.18.0.2 --privileged=true -d --dns 8.8.8.8 -p 8080:8080 -p 8440:8440 -p 8441:8441 -p 16000:16000 -p 50070:50070 -p 8020:8020 -e AMBARI_SERVER=node1  --name node1 -h node1 -i -t ambari_2_server_node
IP_namenode=$(docker inspect --format "{{ .NetworkSettings.Networks.hdp_bridge.IPAddress }}" node1)
echo "Namenode/Ambari Server started at $IP_namenode"

#Start the ResourceManager
echo "Starting ResourceManager..."
docker run --network=hdp_bridge --ip=172.18.0.3 --privileged=true -d --link node1:node1 -e namenode_ip=$IP_namenode --dns 8.8.8.8 -p 8088:8088 -p 8032:8032 -p 50060:50060 -p 8081:8081 -p 8030:8030 -p 8050:8050 -p 8025:8025 -p 8141 -p 8440 -p 8441 -p 19888:19888 -p 45454 -p 10020:10020 -p 22 --name node2 -h node2 -i -t ambari_2_agent_node
IP_resourcemanager=$(docker inspect --format "{{ .NetworkSettings.Networks.hdp_bridge.IPAddress }}" node2)
echo "ResourceManager running on $IP_resourcemanager"

#Start the Hive/Oozie Server
echo "Starting a Hive/Oozie server..."
docker run --network=hdp_bridge --ip=172.18.0.4 --privileged=true -d --link node1:node1 -e namenode_ip=$IP_namenode --dns 8.8.8.8 -p 11000:11000 -p 2181 -p 50111:50111 -p 9083 -p 10000 -p 9999:9999 -p 9933:9933 -p 22 -p 8440 -p 8441 --name node3 -h node3 -i -t ambari_2_agent_node
IP_hive=$(docker inspect --format "{{ .NetworkSettings.Networks.hdp_bridge.IPAddress }}" node3)
echo "Hive/Oozie running on $IP_hive"

#Start two worker nodes
docker run --network=hdp_bridge --ip=172.18.0.5 --privileged=true -d --dns 8.8.8.8 -h node4 --name node4 -p 22 --link node1:node1 -p 8440 -p 8441 -p 6667 -i -t ambari_2_agent_node
IP_node=$(docker inspect --format "{{ .NetworkSettings.Networks.hdp_bridge.IPAddress }}" node4)
echo "Started worker node4 on IP $IP_node"

docker run --network=hdp_bridge --ip=172.18.0.6 --privileged=true -d --dns 8.8.8.8 -h node5 --name node5 -p 22 --link node1:node1 -p 8440 -p 8441 -p 6667 -i -t ambari_2_agent_node
IP_node=$(docker inspect --format "{{ .NetworkSettings.Networks.hdp_bridge.IPAddress }}" node5)
echo "Started worker node5 on IP $IP_node"


