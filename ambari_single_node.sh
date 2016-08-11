#!/bin/bash
if [[ -z $(docker network inspect --format "{{.Name}}" hdp_bridge)  ]]; then
  echo "creating hdp_bridge network"
  docker network create --driver=bridge --subnet=172.18.0.0/16 --ip-range=172.18.0.1/10 hdp_bridge
fi

BLUEPRINT_BASE=$1
: ${BLUEPRINT_BASE:="singlenode"}

Start the Ambari Server 
#echo "Starting Namenode/Ambari Server..."
docker run  --network=hdp_bridge --ip=172.18.0.2  --privileged=true -d --dns 8.8.8.8 -p 8080:8080 -p 8440:8440 -p 8441:8441 -p 50070:50070 -p 8020:8020 -e AMBARI_SERVER=node1 -e BLUEPRINT_BASE=${BLUEPRINT_BASE} --name snode -h node1 -i -t ambari_2_server_node
IP_namenode=$(docker inspect --format "{{ .NetworkSettings.Networks.hdp_bridge.IPAddress }}" snode)
echo "Namenode/Ambari Server started at $IP_namenode"
echo "The Ambari Server will start Blueprint install $BLUEPRINT_BASE"

