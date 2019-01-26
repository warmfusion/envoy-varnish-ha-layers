#!/bin/bash


VARNISH_VERSION=5.2.1-1~stretch
IMAGE_TAG=${CI_BUILD_TAG:-latest}

echo "Building varnish container ..."
docker build --build-arg version=${VARNISH_VERSION} -f Dockerfile.varnish -t docker.artifactory.futurenet.com/tjackson02/varnish:${VARNISH_VERSION} .


echo "Building envoy containers ..."
docker build --build-arg mode=edge -f Dockerfile.envoy -t docker.artifactory.futurenet.com/tjackson02/evha-edge:${IMAGE_TAG} .
docker build --build-arg mode=origin -f Dockerfile.envoy -t docker.artifactory.futurenet.com/tjackson02/evha-origin:${IMAGE_TAG} .

echo "Building test-app container ..."
cd  src/service
docker build -t docker.artifactory.futurenet.com/tjackson02/evha-test-app:${IMAGE_TAG} .
cd -


echo "Pushing containers..."

docker push docker.artifactory.futurenet.com/tjackson02/varnish:${VARNISH_VERSION}
docker push docker.artifactory.futurenet.com/tjackson02/evha-edge:${IMAGE_TAG}
docker push docker.artifactory.futurenet.com/tjackson02/evha-origin:${IMAGE_TAG}
docker push docker.artifactory.futurenet.com/tjackson02/evha-test-app:${IMAGE_TAG}