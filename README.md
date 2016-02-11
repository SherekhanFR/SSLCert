# Survival guide to generate, certify and manage SSL Certificate with Letsencrypt and Apache Tomcat 7

###useful links : 
- Letsencrypt documentation : https://letsencrypt.readthedocs.org/en/latest/
- Apache Tomacat documentation : https://tomcat.apache.org/tomcat-7.0-doc/index.html
- The most important Keytool command : https://www.sslshopper.com/article-most-common-java-keytool-keystore-commands.html
- Java Keytool documentation : http://docs.oracle.com/javase/7/docs/technotes/tools/solaris/keytool.html

### 1/ Prepare the Keystore

	keytool -genkey -alias tomcat -keyalg RSA

This will result in the creation of a keystore for the user tomcat ; The keystore file (.keystore) will be available in the tomcat homedir (/usr/share/tomcat7/.keystore)

### 2/ Generate the certificate and certify by Letsencrypt CA

Test mode : 

	./letsencrypt-auto certonly --standalone --test-cert -d $mydomain --standalone-supported-challenges http-01 --http-01-port 8080 --renew-by-default --email $myemail --agree-tos

	With :
	 - standalone : the mode in which Letsencrypt is ran. This mode does not need any web server to perform the DNS challenge to authenticate your domain, letsencrypt client does it on its own.
	 - $mydomain : the domain to be certified. Some domains are blacklisted (http://www.alexa.com/topsites) during the Letsencrypt beta program.
	 - 8080 : the port used by letsencrypt client to do the DNS challenge
	 - $myemail : the email address linked with the certificate
	
Normal mode :
	
	./letsencrypt-auto certonly --standalone -d $mydomain --standalone-supported-challenges http-01 --http-01-port 8080 --renew-by-default --email $myemail --agree-tos
	
	With :
	 - standalone : the mode in which Letsencrypt is ran. This mode does not need any web server to perform the DNS challenge to authenticate your domain, letsencrypt client does it on its own.
	 - $mydomain : the domain to be certified. Some domains are blacklisted (http://www.alexa.com/topsites) during the Letsencrypt beta program.
	 - 8080 : the port used by letsencrypt client to do the DNS challenge
	 - $myemail : the email address linked with the certificate
	
Use the Test mode until you are ready as you cannot try a lot of authentications on the same domain with "normal" mode.

### 2/ Install the certifate into the keystore

Remove previously installed certificates (usefull if you script the generation of the certificate)

	keytool -delete -alias root -storepass changeit -keystore $keystoredir
	keytool -delete -alias tomcat -storepass changeit -keystore $keystoredir

	With :
	 - changeit : the password of the keystore
	 - $keystoredir : the path of your keystore (created in step1)
	
Export the certificate in pkcs12 format (execute the command from a dedicated "certificate" directory for easy access)
	
	openssl pkcs12 -export -in $certdir/fullchain.pem -inkey $certdir/privkey.pem -out $certdir/cert_and_key.p12 -name tomcat -CAfile $certdir/chain.pem -caname root -password pass:changeit

	With :
	 - $certdir the path of generated certificates (pem files) (generally in Letsencrypt_path/live/domain/*)
	 - changeit : the password of pkcs12 file

Import the certificate into the keystore
	 
	keytool -importkeystore -srcstorepass changeit -deststorepass changeit2 -destkeypass changeit3 -srckeystore $certdir/cert_and_key.p12 -srcstoretype PKCS12 -alias tomcat -keystore $keystoredir
	
	with :
	  - changeit : the password of pkcs12 source file (generated above)
	  - changeit2 : the password of the destination keystore
	  - changeit3 : the key of the destination keystore
	  - $certdir the path the generated certificate (generally in Letsencrypt_path/live/domain/*)
	  - $keystoredir : the path of your keystore (created in step1)
	
	keytool -import -trustcacerts -alias root -deststorepass changeit2 -file $certdir/chain.pem -noprompt -keystore $keystoredir

	with :
	  - changeit2 : the password of the destination keystore
	  - $certdir the path the generated certificate (generally in Letsencrypt_path/live/domain/*)
	  - $keystoredir : the path of your keystore (created in step1)