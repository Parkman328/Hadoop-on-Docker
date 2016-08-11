docker rmi ambari_2_node
docker rmi ambari_2_server_node
docker rmi ambari_2_agent_node

#Building base node: ambari_2_node 
cd ambari_2_node
docker build -t ambari_2_node .

#Building server node: ambari_2_server_node
cd ../ambari_2_server_node
docker build -t ambari_2_server_node .

#Building agent node: ambari_2_agent_node
cd ../ambari_2_agent_node
docker build -t ambari_2_agent_node .
