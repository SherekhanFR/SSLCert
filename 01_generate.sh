#!/bin/bash
#author ShereKhanFR based on Ivan Tichy script (https://community.letsencrypt.org/t/lets-encrypt-and-jira-tomcat-fully-automated-script/8164)

#Please modify these values according to your environment
certdir=/etc/letsencrypt/live/example.com/ #just replace the domain name after /live/
mydomain=www.example.com #put your domain name here
myemail=contact@example.com #your email
keystoredir=/usr/share/tomcat7/.keystore #located in home dir of user that you Tomcat is running under
KEYSTORE_PASS = 1234
KEY_PASS = 1234
PKCS12_PASS = 1234

sudo service tomcat7 stop

#the script itself:
cd /etc/letsencrypt

./letsencrypt-auto certonly --standalone --test-cert -d $mydomain --standalone-supported-challenges http-01 --http-01-port 8080 --renew-by-default --email $myemail --agree-tos
#./letsencrypt-auto certonly --standalone -d $mydomain --standalone-supported-challenges http-01 --http-01-port 8080 --renew-by-default --email $myemail --agree-tos

keytool -delete -alias root -storepass KEYSTORE_PASS -keystore $keystoredir
keytool -delete -alias tomcat -storepass KEYSTORE_PASS -keystore $keystoredir

openssl pkcs12 -export -in $certdir/fullchain.pem -inkey $certdir/privkey.pem -out $certdir/cert_and_key.p12 -name tomcat -CAfile $certdir/chain.pem -caname root -password pass:PKCS12_PASS

keytool -importkeystore -srcstorepass PKCS12_PASS -deststorepass KEYSTORE_PASS -destkeypass KEY_PASS -srckeystore $certdir/cert_and_key.p12 -srcstoretype PKCS12 -alias tomcat -keystore $keystoredir
keytool -import -trustcacerts -alias root -deststorepass KEYSTORE_PASS -file $certdir/chain.pem -noprompt -keystore $keystoredir

# restart your Tomcat server
sudo service tomcat7 start
