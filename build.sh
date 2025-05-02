#!/bin/bash

docker build . --tag sdkman_proxy


# copy cert from docker:
id=$(docker create sdkman_proxy)
docker cp $id:/ssl_cert - > ssl_cert.tar
docker rm -v $id
tar -xvf ssl_cert.tar
cp ./ssl_cert/squid-self-signed.pem ./proxy_sdkman
mkdir data
mkdir logs
chmod go+rw data
chmod go+rw logs
