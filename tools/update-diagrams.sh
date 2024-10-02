#!/bin/bash

set -e

SCRIPT=$(readlink -f $0)
BASEDIR=$(dirname $SCRIPT)/..

docker run \
	--user $UID:$GID \
	--rm \
	-v ./docs:/usr/local/structurizr \
	structurizr/cli export -f plantuml -o images -w workspace.dsl

docker run \
	--rm \
	--user $UID:$GID \
	-v $BASEDIR/docs:/data/docs \
	plantuml/plantuml -tsvg docs/images
