#!/bin/sh

#https://gist.github.com/dasniko/b1aa115fd9078372b03c7a9f7e9ec189
#https://www.baeldung.com/x-509-authentication-in-spring-security

ca_dir="/ca-gen/ca"

mkdir -p /ca-gen/clients

createRootCA(){
    openssl req \
      -x509 \
      -sha256 \
      -days 3650 \
      -newkey rsa:4096 \
      -passout pass:foobar \
      -subj '/C=BR/ST=SP/L=SAO PAULO/O=Debug Corp/OU=Debug Org Unit/CN=debug.corp' \
      -keyout ${ca_dir}/rootCA.key \
      -out ${ca_dir}/rootCA.crt
      cp ${ca_dir}/rootCA.crt /etc/ssl/certs/
      cp ${ca_dir}/rootCA.crt /ca-gen/clients
}

hostCertificate(){
    dns=$1
    openssl req \
      -new \
      -newkey rsa:4096 \
      -subj "/C=BR/ST=SP/L=SAO PAULO/O=Debug Corp/OU=Debug Org Unit/CN=${dns}" \
      -keyout "${ca_dir}/${dns}.key" \
      -out "${ca_dir}/${dns}.csr" \
      -nodes
}

createExt() {
dns=$1
cat > "/ca-gen/${dns}.ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${dns}
EOF
}

signHostWithRootCA(){
    dns=$1
    openssl x509 \
      -req \
      -CA ${ca_dir}/rootCA.crt \
      -CAkey ${ca_dir}/rootCA.key \
      -passin pass:foobar \
      -in "${ca_dir}/${dns}.csr" \
      -out "${ca_dir}/${dns}.crt" \
      -days 365 \
      -CAcreateserial \
      -extfile "/ca-gen/${dns}.ext"
}

copyHostCertKey(){
    dns=$1
    cp "${ca_dir}/${dns}.key" /etc/ssl/certs/
    cp "${ca_dir}/${dns}.crt" /etc/ssl/certs/
}

if [ ! -d ${ca_dir} ]
then
    mkdir -p ${ca_dir}
    createRootCA
    
    for template in /etc/nginx/templates/*.conf.template; do
      filename=$(basename -- "${template}")
      dns="${filename/.conf.template/}"
      echo "${dns}"
      createExt "${dns}"
      hostCertificate "${dns}"
      createExt "${dns}"
      signHostWithRootCA "${dns}"
      copyHostCertKey "${dns}"
      echo "";
    done

else
    cp /ca-gen/ca/* /etc/ssl/certs/
fi


