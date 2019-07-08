#!/bin/bash

echo "REMOVING EXISTENT CONTAINERS"
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
rm -rf ./minimal-nodeschool
rm -rf ./nodeschool-servers
rm config.json

export PUBLIC_IP=`curl https://ipinfo.io/ip`
export CONTAINERS_COUNT=$1

# Creates folders
for i in $(seq 1 2 $((CONTAINERS_COUNT*2))); do mkdir -p nodeschool-servers/$i; cp -a ./introduction.md nodeschool-servers/$i; done

for i in $(seq 1 2 $((CONTAINERS_COUNT*2))); do
	docker run -e "SERVE_PORT=$((8442+$i+1))" -e "URL=$PUBLIC_IP" -d -p 0.0.0.0:$((8442+$i)):8443 -p 0.0.0.0:$((8442+$i+1)):5000 --entrypoint "/bin/bash" -v "${PWD}/nodeschool-servers/$i:/root/project" --name nodeschool_server_$i a0viedo/code-server initialize;
done

# Extracts config.json
docker ps -q | xargs -n1 -I{} sh -c 'docker logs {} | tail -10' | grep Password | cut -d' ' -f4 | START_PORT=8443 npx https://gist.github.com/a0viedo/6707a836b16621263a31e7bd149bb6d8

# Check if folder is missing
[ ! -d "./minimal-nodeschool" ] && git clone https://github.com/a0viedo/minimal-nodeschool

cp ./config.json ./minimal-nodeschool

cd ./minimal-nodeschool

now
now alias $2

echo "DONE"
