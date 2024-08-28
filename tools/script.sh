#!/usr/bin/env bash

set -e

ARGUMENTS="$@"

REMOVE=false
CLEAR_CONFIG=false
AUTOPILOT=false
BUILD=false

# Function to display script usage
function display_usage() {
    echo "Usage: $0 [-h|--help] [-r|--remove] [-c|--clear-config] [-a|--autopilot] [-- command]"
    echo "Options:"
    echo "  -h, --help                      Display this help message"
    echo "  -r, --remove                    Docker compose stop and remove"
    echo "  -c, --clear-config              Remove the local config files"
    echo "  -a, --autopilot                 Copy the env files from the example files in each repository"
    echo "  -b  --build                     Rebuild the docker containers"
    echo "  --                              Everything behind the -- is executed in every module"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h | --help)
            display_usage
            ;;
        -r | --remove)
            REMOVE=true
            shift
            ;;
        -c | --clear-config)
            CLEAR_CONFIG=true
            shift
            ;;
        -a | --autopilot)
            AUTOPILOT=true
            shift
            ;;
        -b | --build)
            BUILD=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`/../../

cd $BASEDIR

MODULES="nl-irealisatie-zmodules-pgo-demo nl-irealisatie-zmodules-addressing-register gfmodules-localization-register-service gfmodules-localization-metadata-register nl-irealisatie-zmodules-pseudonym-service"

for module in $MODULES ; do
  if [ ! -d "$module" ] ; then
    git clone git@github.com:minvws/${module}.git
  fi
done

if "$REMOVE" || "$CLEAR_CONFIG" ; then
    cd $BASEDIR/gfmodules-coordination
    if "$REMOVE" ; then
      docker compose stop
      docker compose rm -f
    fi

    for module in $MODULES ; do
      cd $BASEDIR/${module}
      echo "=== ${module} ==="
      if "$REMOVE" ; then
        docker compose stop
        docker compose rm -f
      fi
      if "$CLEAR_CONFIG" ; then
        rm app.conf || true
        rm .env.local || true
        rm .autopilot || true
      fi
      echo "==="
    done
fi

if "$AUTOPILOT"; then
    cd $BASEDIR/gfmodules-coordination
    if "$BUILD"; then
      docker compose build
    fi
    docker compose up -d --remove-orphans
    for module in $MODULES ; do
        echo "=== Start ${module} with preconfigured autopilot configuration ==="
        cd $BASEDIR/${module}

        if [ -e tools/autopilot.sh ]; then
          tools/./autopilot.sh
        else
          if "$BUILD"; then
            docker compose build
          fi
          docker compose up -d --remove-orphans
        fi

        echo "==="
    done
fi

if "$AUTOPILOT"; then
  cat << "EOF"


 ______                    _       _
|___  /                   | |     | |
   / / _ __ ___   ___   __| |_   _| | ___  ___
  / / | '_ ` _ \ / _ \ / _` | | | | |/ _ \/ __|
./ /__| | | | | | (_) | (_| | |_| | |  __/\__ \
\_____/_| |_| |_|\___/ \__,_|\__,_|_|\___||___/


ZModules should be installed. Either use the APIs:

  Localisation register: http://localhost:8501/docs
  Addressing register: http://localhost:8502/docs
  Metadata register: http://localhost:8503/docs
  Pseudonym service: http://localhost:8504/docs
  Timeline service: http://localhost:8505/docs

Or the frontend demo at: http://localhost:8500

EOF
fi
