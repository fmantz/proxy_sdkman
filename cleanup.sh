# delete everything that was generated:
docker-compose down
rm -rf ./data
rm -rf ./logs
rm -rf ./ssl_cert.tar
rm -rf ./ssl_cert
rm ./proxy_sdkman/squid-self-signed.pem
