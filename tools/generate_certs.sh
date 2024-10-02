#!/usr/bin/env bash

set -e

SECRETS_DIR=secrets

# Creates a CA certificate and key pair
create_ca() {
  local cert_name=${1}

  echo "* Generating CA certificate for ${cert_name}"

  if [[ -f $SECRETS_DIR/${cert_name}.crt ]]; then
    echo "! CA certificate already exist. Skipping"
    return
  fi

  openssl genrsa -out $SECRETS_DIR/${cert_name}.key 4096
  openssl req -x509 -new -nodes -sha256 -days 1024 \
    -key $SECRETS_DIR/${cert_name}.key \
    -out $SECRETS_DIR/${cert_name}.crt \
    -subj "/C=NL/L=Den Haag/O=MinVWS/OU=RDO/CN=gfmodules-dev-${cert_name}-ca"

  openssl pkcs12 -export -out $SECRETS_DIR/${cert_name}.pfx -inkey $SECRETS_DIR/${cert_name}.key -in $SECRETS_DIR/${cert_name}.crt -passout pass:notsecret
}


# Creates an intermediate certificate and key pair, base on the CA certificate
create_intermediate() {
  local im_name=${1}
  local ca_name=${2}

  echo "* Generating intermediate certificate for ${im_name} based on ${ca_name}"

  if [[ -f $SECRETS_DIR/${im_name}.crt ]]; then
    echo "! Intermediate certificate already exist. Skipping"
    return
  fi

  openssl genrsa -out $SECRETS_DIR/${im_name}.key 4096
  openssl req -new -sha256 \
    -key $SECRETS_DIR/${im_name}.key \
    -out $SECRETS_DIR/${im_name}.csr \
    -subj "/C=NL/L=Den Haag/O=MinVWS/OU=RDO/CN=gfmodules-dev-${im_name}-intermediate"

  openssl x509 -req -sha256 --days 1024 \
    -in $SECRETS_DIR/${im_name}.csr \
    -CA $SECRETS_DIR/${ca_name}.crt \
    -CAkey $SECRETS_DIR/${ca_name}.key \
    -CAcreateserial \
    -out $SECRETS_DIR/${im_name}.crt \
    -extfile <(echo "basicConstraints=critical,CA:TRUE,pathlen:0")

    rm $SECRETS_DIR/${im_name}.csr

    openssl pkcs12 -export -out $SECRETS_DIR/${im_name}.pfx -inkey $SECRETS_DIR/${im_name}.key -in $SECRETS_DIR/${im_name}.crt -passout pass:notsecret
}


# Creates a client certificate and key pair, based on the CA certificate
create_client_cert () {
  local cert_name=${1}
  local ca_name=${2}

  echo "* Generating client certificate for ${cert_name} based on ${ca_name}"

  local full_base=$SECRETS_DIR/${cert_name}/${cert_name}
  local full_ca_base=$SECRETS_DIR/${ca_name}

  if [[ -f ${full_base}.crt ]]; then
    echo "! Certificate already exist. Skipping"
    return
  fi

  echo "generating keypair and certificate ${cert_name} in ${cert_name} with CN:${cert_name}"
  mkdir -p `dirname "${full_base}.crt"`

  openssl genrsa -out ${full_base}.key 3072
  openssl rsa -in ${full_base}.key -pubout > ${full_base}.pub

  openssl req -new -sha256 \
    -key ${full_base}.key \
    -subj "/C=NL/L=Den Haag/O=MinVWS/OU=RDO/CN=${cert_name}" \
    -out ${full_base}.csr

  openssl x509 -req -days 500 -sha256 \
    -in ${full_base}.csr \
    -CA ${full_ca_base}.crt \
    -CAkey ${full_ca_base}.key \
    -CAcreateserial \
    -out ${full_base}.crt

  rm ${full_base}.csr

  openssl pkcs12 -export -out ${full_base}.pfx -inkey ${full_base}.key -in ${full_base}.crt -passout pass:notsecret
}


# Creates an UZI certificate and key pair, based on the CA certificate
create_uzi_cert () {
  local cert_name=${1}
  local ura_number=${2}
  local ca_name=${3}

  echo "* Generating UZI certificate for ${cert_name} based on ${ca_name}"

  local full_base=$SECRETS_DIR/${cert_name}/${cert_name}
  local full_ca_base=$SECRETS_DIR/${ca_name}

  if [[ -f ${full_base}.crt ]]; then
    echo "! Certificate already exist. Skipping"
    return
  fi

  mkdir -p `dirname "${full_base}.crt"`

  openssl genrsa -out ${full_base}.key 3072
  openssl rsa -in ${full_base}.key -pubout > ${full_base}.pub

  openssl req -new -sha256 \
    -key ${full_base}.key \
    -subj "/C=NL/L=Den Haag/O=MinVWS/OU=RDO/CN=${cert_name}/serialNumber=1234ABCD" \
    -addext "subjectAltName = otherName:2.5.5.5;IA5STRING:2.16.528.1.1003.1.3.5.5.2-1-12345678-S-$ura_number-00.000-00000000,DNS:${cert_name}" \
    -addext "certificatePolicies = 2.16.528.1.1003.1.2.8.6" \
    -addext "extendedKeyUsage = serverAuth,clientAuth" \
    -out ${full_base}.csr

  openssl x509 -req -days 500 -sha256 \
    -in ${full_base}.csr \
    -CA ${full_ca_base}.crt \
    -CAkey ${full_ca_base}.key \
    -CAcreateserial \
    -copy_extensions copyall \
    -out ${full_base}.crt

  rm ${full_base}.csr
  chmod +r ${full_base}.key

  openssl pkcs12 -export -out ${full_base}.pfx -inkey ${full_base}.key -in ${full_base}.crt -certfile ${full_ca_base}.crt -passout pass:notsecret
}


create_ca "uzi-server-ca"
create_intermediate "im1-uzi-server" "uzi-server-ca"
create_intermediate "im2-uzi-server" "uzi-server-ca"

create_uzi_cert timeline 90000001 "uzi-server-ca"
create_uzi_cert localization 90000002 "uzi-server-ca"
create_uzi_cert addressing 90000004 "uzi-server-ca"

create_uzi_cert prs.local 90000012 "uzi-server-ca"
create_uzi_cert prs.local 90000012 "uzi-server-ca"
create_uzi_cert prs-client-1.local 90000024 "im1-uzi-server"
create_uzi_cert prs-client-2.local 90000036 "im2-uzi-server"
create_uzi_cert prs-client-3.local 90000048 "uzi-server-ca"
