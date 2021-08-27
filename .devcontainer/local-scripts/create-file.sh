#!/usr/bin/env bash

ENV_PATH=${1:-".devcontainer/devcontainer.env"}

if [ ! -f $ENV_PATH ] ; then
    echo "$ENV_PATH does not yet exist. Creating..."
    touch $ENV_PATH
fi
