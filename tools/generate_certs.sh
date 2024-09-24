#!/usr/bin/env bash

set -e

SECRETS_DIR=secrets


create_ca() {
  local base_name=${1}-ca

  if [[ ! -f $SECRETS_DIR/$base_name.crt ]]; then
    rm -f $SECRETS_DIR/$base_name.crt $SECRETS_DIR/$base_name.key
    openssl genrsa -out $SECRETS_DIR/$base_name.key 4096
    openssl req -x509 -new -nodes -sha256 -days 1024 \
      -key $SECRETS_DIR/$base_name.key \
      -out $SECRETS_DIR/$base_name.crt \
      -subj "/C=NL/L=Den Haag/O=MinVWS/OU=RDO/CN=gfmodules-dev-$base_name-ca"
  fi
}


create_key_pair () {
  local base_name=${1}
  local ca_base_name="ssl-ca"

  local full_base=$SECRETS_DIR/$base_name/$base_name
  local full_ca_base=$SECRETS_DIR/$ca_base_name

  create_ca "ssl"

  if [[ ! -f $full_base.crt ]]; then
    rm -f $full_base.crt $full_base.csr $full_base.key

    echo "generating keypair and certificate $base_name in $base_name with CN:$base_name"
    mkdir -p `dirname "$full_base.crt"`
    openssl genrsa -out $full_base.key 3072
    openssl rsa -in $full_base.key -pubout > $full_base.pub
    openssl req -new -sha256 \
      -key $full_base.key \
      -subj "/C=NL/L=Den Haag/O=MinVWS/OU=RDO/CN=$base_name" \
      -out $full_base.csr
    openssl x509 -req -days 500 -sha256 \
      -in $full_base.csr \
      -CA $full_ca_base.crt \
      -CAkey $full_ca_base.key \
      -CAcreateserial \
      -out $full_base.crt
    rm $full_base.csr
  fi
}


create_uzi_key_pair () {
  local base_name=${1}
  local ura_number=${2}
  local ca_base_name="uzi-server-ca"

  local full_base=$SECRETS_DIR/$base_name/$base_name
  local full_ca_base=$SECRETS_DIR/$ca_base_name

  create_ca "uzi-server"

  if [[ ! -f $full_base.crt ]]; then
    rm -f $full_base.crt $full_base.csr $full_base.key

    echo "generating keypair and certificate $base_name in $SECRETS_DIR/$base_name with CN:$base_name"
    mkdir -p `dirname "$full_base.crt"`
    openssl genrsa -out $full_base.key 3072
    openssl rsa -in $full_base.key -pubout > $full_base.pub
    openssl req -new -sha256 \
      -key $full_base.key \
      -subj "/C=NL/L=Den Haag/O=MinVWS/OU=RDO/CN=$base_name/serialNumber=1234ABCD" \
      -addext "subjectAltName = otherName:2.5.5.5;IA5STRING:2.16.528.1.1003.1.3.5.5.2-1-12345678-S-$ura_number-00.000-00000000,DNS:$base_name" \
      -addext "certificatePolicies = 2.16.528.1.1003.1.2.8.6" \
      -addext "extendedKeyUsage = serverAuth,clientAuth" \
      -out $full_base.csr
    openssl x509 -req -days 500 -sha256 \
      -in $full_base.csr \
      -CA $full_ca_base.crt \
      -CAkey $full_ca_base.key \
      -CAcreateserial \
      -copy_extensions copyall \
      -out $full_base.crt
    rm $full_base.csr
    chmod +r $full_base.key
  fi
}

create_uzi_key_pair timeline 90000001
create_uzi_key_pair localization 90000002
create_uzi_key_pair prs 90000003
