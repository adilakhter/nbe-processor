
# Run redis 
docker run --name nbe-redis -d redis

# run node-processor 
docker run -it -P --name nbe-processor --link nbe-redis:redis adilakhter/ubuntu-nbe-processor /bin/bash

# Execute nbe-processor 

cd src 
nodejs nbe-processor-runner.js resources/input.nbe 


# To interact with the remote redis server 
# install redis-cli 
apt-get install redis
sudo service redis-server stop

# To connect to the rmeote redis 

redis-cli -h $REDIS_PORT_6379_TCP_ADDR