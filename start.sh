#!/bin/bash

docker rm -f htcnet
docker run --privileged --name htcnet -d \
	-v /srv/htcnet:/data \
	htcnet
    