#!/bin/bash


echo "Building varnish container ..."
docker build --build-arg version=5.2.1-1~stretch -f Dockerfile.varnish -t warmfusion/varnish:5.2.1-1-stretch .


echo "Building envoy containers ..."
docker build --build-arg mode=edge -f Dockerfile.envoy -t warmfusion/evhl-edge:latest .
docker build --build-arg mode=origin -f Dockerfile.envoy -t warmfusion/evhl-origin:latest .

echo "Building test-app container ..."
cd  src/service
docker build -t warmfusion/evhl-test-app:latest .
cd -
