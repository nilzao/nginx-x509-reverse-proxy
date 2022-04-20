#!/bin/sh

#https://gist.github.com/dasniko/b1aa115fd9078372b03c7a9f7e9ec189
#https://www.baeldung.com/x-509-authentication-in-spring-security

if [ "$#" -ne 3 ]
then
 echo "this script needs 3 parameters"
 exit 1
fi

ca_dir="/ca-gen/ca"
ca_client_dir="/ca-gen/clients"

name=$1
cn=$2
email=$3

#Client (user) certificate
openssl req \
  -new \
  -newkey rsa:4096 \
  -subj "/C=BR/ST=SP/L=SAO PAULO/O=Debug Corp/OU=Debug Org Unit/CN=${cn}/emailAddress=${email}" \
  -nodes \
  -keyout ${ca_client_dir}/${name}.key \
  -out ${ca_client_dir}/${name}.csr

#Sign client csr with rootCA:
openssl x509 \
  -req \
  -CA ${ca_dir}/rootCA.crt \
  -CAkey ${ca_dir}/rootCA.key \
  -passin pass:foobar \
  -in ${ca_client_dir}/${name}.csr \
  -out ${ca_client_dir}/${name}.crt \
  -days 365 \
  -CAcreateserial

#Import client key and crt in keystore to create the "certificate" to be used in the browser:
openssl pkcs12 \
  -export \
  -out ${ca_client_dir}/${name}.p12 \
  -name "${name}" \
  -passout pass: \
  -inkey ${ca_client_dir}/${name}.key \
  -in ${ca_client_dir}/${name}.crt

chmod 666 ${ca_client_dir}/${name}.p12

