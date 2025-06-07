# proxy_sdkman

Hello,

I tried to configure squid so that I can use it with sdkman (https://sdkman.io/).
My aim was to save some bandwidth when installing jdks, scala etc. on different computers.
Furthermore, I wanted to keep the setup simple, therefore I wanted to run it in docker.

I basically followed the instruction from this side:
- https://rasika90.medium.com/how-i-saved-tons-of-gbs-with-https-caching-41550b4ada8a

What I did not manage is to use sdkman also without internet connection.
This may not even be possible, so far as I understood:
- https://www.oreilly.com/library/view/squid-the-definitive/0596001622/re169.html

The setup is a basic setup and may need to be polished for your needs.
Docker and docker-compose are required before you start. In addition, I assume a linux pc.

# Setup Squid for SDKMAN! 

```
# build and start:
./build.sh
./start.sh &
```

Open an new terminal:

```
# install local:
cp -r proxy_sdkman ~
mv ~/proxy_sdkman ~/.proxy_sdkman
export WGETRC=~/.proxy_sdkman/.proxy_wgetrc
export CURL_HOME=~/.proxy_sdkman

# hardcode your home directory using an absolute path:
nano ~/.proxy_sdkman/.curlrc
```

# Test Squid:

```
# test via curl:

wget https://github.com/squid-cache/squid/releases/download/SQUID_6_13/squid-6.13.tar.gz
wget https://github.com/squid-cache/squid/releases/download/SQUID_6_13/squid-6.13.tar.gz

sudo cat ./logs/access.log

1746186876.998     94 172.21.0.1 NONE_NONE/200 0 CONNECT github.com:443 - HIER_DIRECT/140.82.121.4 -
1746186877.206    206 172.21.0.1 TCP_MISS/302 4545 GET https://github.com/squid-cache/squid/releases/download/SQUID_6_13/squid-6.13.tar.gz - HIER_DIRECT/140.82.121.4 text/html
1746186877.286     78 172.21.0.1 NONE_NONE/200 0 CONNECT objects.githubusercontent.com:443 - HIER_DIRECT/185.199.111.133 -
1746186878.523   1234 172.21.0.1 TCP_MISS/200 5472531 GET https://objects.githubusercontent.com/github-production-release-asset-2e65be/24519987/0ee8b130-15e1-4802-b17a-77e90d4d48e8? - HIER_DIRECT/185.199.111.133 application/octet-stream
1746186881.581     78 172.21.0.1 NONE_NONE/200 0 CONNECT github.com:443 - HIER_DIRECT/140.82.121.4 -
1746186881.593     10 172.21.0.1 TCP_MISS/302 4544 GET https://github.com/squid-cache/squid/releases/download/SQUID_6_13/squid-6.13.tar.gz - HIER_DIRECT/140.82.121.4 text/html
1746186881.667     72 172.21.0.1 NONE_NONE/200 0 CONNECT objects.githubusercontent.com:443 - HIER_DIRECT/185.199.111.133 -
1746186881.790    120 172.21.0.1 TCP_OFFLINE_HIT/200 5472574 GET https://objects.githubusercontent.com/github-production-release-asset-2e65be/24519987/0ee8b130-15e1-4802-b17a-77e90d4d48e8? - HIER_NONE/- applicatio
```

Note in the last line ***TCP_OFFLINE_HIT***

```
# test via sdkman:

sdk install java 24-tem
sdk uninstall java 24-tem
sdk install java 24-tem

sudo cat ./logs/access.log

1746187760.552     41 172.21.0.1 NONE_NONE/200 0 CONNECT objects.githubusercontent.com:443 - HIER_DIRECT/185.199.111.133 -
1746187762.657   2104 172.21.0.1 TCP_OFFLINE_HIT/200 139206374 GET https://objects.githubusercontent.com/github-production-release-asset-2e65be/816881012/168bc02e-b361-47ae-abe1-50404a62b265? - HIER_NONE/- application/octet-stream
1746187762.885    214 172.21.0.1 NONE_NONE/200 0 CONNECT api.sdkman.io:443 - HIER_DIRECT/45.55.42.78 -
1746187762.886      0 172.21.0.1 TCP_MEM_HIT/200 1409 GET https://api.sdkman.io/2/hooks/post/java/24-tem/linuxx64 - HIER_NONE/- text/plain
```

# Stop Squid

```
./stop.sh
```

**ATTENTION:**
do not use docker-compose down, it will destroy the container which results that all cached objects, 
even still in the cache directory become invalid and need to be reload from the web after a restart.

# Cleanup

```
sudo ./cleanup.sh
```

Note, this step needs to be run as root, it also removes the generated certificates, in the working directory and also the container. However, the image is not removed.

# Use the proxy from a different computer:

To use the proxy from a different computer, simply copy directory proxy_sdkman to it and update ".curlrc".
Only the IP and the directory to the certificate have to be changed. 
