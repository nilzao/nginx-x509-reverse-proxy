# nginx-x509-reverse-proxy

Nginx docker image with openssl scripts to debug x509 client auth

References:

https://gist.github.com/dasniko/b1aa115fd9078372b03c7a9f7e9ec189

https://www.baeldung.com/x-509-authentication-in-spring-security

example to build and run:

```
docker build . -t nginx-ca:latest

docker run --rm -it \
 --name nginx \
 -e LOCALHOST_PROXY_PASS="http://192.168.0.2:9999" \
 -e EXAMPLE_PROXY_PASS="http://192.168.0.2:1999" \
 -p 443:443 \
 -v $PWD/clients:/ca-gen/clients \
 nginx-ca:latest

```
---
Create client cert:

```
docker exec -it nginx ./add-cli.sh filename "Cert CN" clientemail@somewhere.com
```
will copy to volume $PWD/clients

---

Using other CA/Certs:

```
docker build . -t nginx-ca:latest

docker run --rm -it \
 --name nginx \
 -e LOCALHOST_PROXY_PASS="http://192.168.0.2:9999" \
 -e EXAMPLE_PROXY_PASS="http://192.168.0.2:1999" \
 -p 443:443 \
 -v $PWD/clients:/ca-gen/clients \
 -v $PWD/ca:/ca-gen/ca \
 nginx-ca:latest

```

---

keycloak parse examples

emailAddress=joe@superserver.com,CN=Joe the super:1234,OU=Debug Org Unit,O=Debug Corp,ST=SP,C=BR

```
regex v1
CN=.*?:(.*?),

regex v2 (e-cpf)
CN=[^:]+:(\d{11}),
```
