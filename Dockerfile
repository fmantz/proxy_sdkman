# UBUNTU LTS VERSION.
FROM ubuntu:24.04
# Prepare
RUN apt-get update
RUN apt-get install -y \
    build-essential \
    openssl \ 
    libssl-dev \ 
    pkg-config \
    wget

# Install Squid manually with SSL_BUMB option.
RUN wget https://github.com/squid-cache/squid/releases/download/SQUID_5_9/squid-5.9.tar.gz
RUN tar -xvf squid-5.9.tar.gz
RUN cd squid-5.9 && ./configure --with-default-user=proxy --with-openssl --enable-ssl-crtd && make && make install

# Configure SSL and create certificates.
COPY ./build/openssl.cnf /etc/ssl/openssl.cnf
RUN mkdir /ssl_cert
# Convert self-signed root cert.
RUN /usr/bin/openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -extensions v3_ca -keyout /ssl_cert/squid-self-signed.key -out /ssl_cert/squid-self-signed.crt -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"
# Convert the cert into a trusted certificate in DER format.
RUN /usr/bin/openssl x509 -in /ssl_cert/squid-self-signed.crt -outform DER -out /ssl_cert/squid-self-signed.der
# Convert the cert into a trusted certificate in PEM format.
RUN /usr/bin/openssl x509 -in /ssl_cert/squid-self-signed.crt -outform PEM -out /ssl_cert/squid-self-signed.pem
# Generate the settings file for the Diffie-Hellman algorithm.
RUN /usr/bin/openssl dhparam -outform PEM -out /ssl_cert/squid-self-signed_dhparam.pem 2048

# Copy certificates.
RUN chmod  ugo+r       /ssl_cert/*
RUN cp     /ssl_cert/* /etc/ssl/certs
RUN cp -rf /ssl_cert   /usr/local/squid/etc/ssl_cert

# Trusted CA into the local machine.
RUN cp /usr/local/squid/etc/ssl_cert/squid-self-signed.pem /usr/local/share/ca-certificates/squid-self-signed.crt

# Update CA certificate cache
RUN update-ca-certificates
COPY ./build/squid.conf /usr/local/squid/etc/squid.conf

# Start squid:
COPY ./build/docker-entrypoint.sh /sbin/docker-entrypoint.sh

EXPOSE 3128/tcp

RUN chmod 755 /sbin/docker-entrypoint.sh
RUN chown -R proxy:proxy /usr/local/squid

# Healthcheck
HEALTHCHECK CMD netstat -an | grep 3128 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

USER proxy
ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
