#!/bin/sh

docker build buildenv -t amplessimus-buildenv || exit 1
docker run --rm -it -v $PWD:/amp amplessimus-buildenv bash
