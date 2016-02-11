# Survival guide to generate, validate and manage SSL Client Certificates with Apache Tomcat 7

###Useful links : 
- Apache Tomacat documentation : https://tomcat.apache.org/tomcat-7.0-doc/index.html
- The most important Keytool command : https://www.sslshopper.com/article-most-common-java-keytool-keystore-commands.html
- Java Keytool documentation : http://docs.oracle.com/javase/7/docs/technotes/tools/solaris/keytool.html

Reminder : some paths are related to my environment (Ubuntu 14.04.3 LTS (GNU/Linux 3.19.0-28-generic x86_64)) location may differ on other platform.

1/ Generate the client key

	openssl genrsa -des3 -out client.key 4096

2/ Generate the client certificate

	openssl req -new -key client.key -out client.csr

3/ Sign the client certificate with the service pem

	Sudo openssl x509 -req -days 365 -in client.csr -CA letsencrypt_path/live/example.com/cert.pem -CAkey letsencrypt_path/live/example.com/privkey.pem -set_serial 01 -out client.crt

4/ Package the client certificate

	openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12

	openssl pkcs12 -in client.p12 -out client.pem -clcerts

5/ Import the certificate in tomcat keystore

	$JAVA_HOME/bin/keytool -importcert -file client.cer -keystore /usr/share/tomcat7/.keystore -storepass KEYSTORE_PASS -noprompt
	
6/ Setup Apache Tomcat 7

	<Connector 	port="8443" protocol="HTTP/1.1" SSLEnabled="true"
				maxThreads="150" scheme="https" secure="true"
				clientAuth="true" sslProtocol="TLS" 
				keystoreFile="${user.home}/.keystore" keystorePass="changeit"
				truststoreFile="${user.home}/.keystore" truststorePass="changeit"
	       />
		   
	with : 
	  - your keystore located in tomcat user directory (/usr/share/tomcat7/.keystore)
	  - changeit the password of your keystore
	  
Reboot tomcat7 service

	$sudo service tomcat7 restart
	
Check the correct start of Apache Tomcat 7 in catalina.out file (/var/lib/tomcat7/logs)

7/ Install the client certificate

Install the client certificate on your OS / browser

8/ Test your certificate

Now if you connect on your server via the certified domain with HTTPS your browser should ask you the client certificate. Provide it and you should be able to get in your server.