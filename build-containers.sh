#!/bin/bash


VARNISH_VERSION=5.2.1-1
IMAGE_TAG=${CI_BUILD_TAG:-master}


echo "Pulling copies of containers to reduce rebuild time..."

docker pull docker.artifactory.futurenet.com/tjackson02/varnish:${VARNISH_VERSION} .
docker pull docker.artifactory.futurenet.com/tjackson02/evha-edge-varnish:${IMAGE_TAG}
docker pull docker.artifactory.futurenet.com/tjackson02/evha-origin-varnish:${IMAGE_TAG}
docker pull docker.artifactory.futurenet.com/tjackson02/evha-edge-envoy:${IMAGE_TAG}
docker pull docker.artifactory.futurenet.com/tjackson02/evha-origin-envoy:${IMAGE_TAG}
docker pull docker.artifactory.futurenet.com/tjackson02/evha-test-app:${IMAGE_TAG}


echo "Failing on any build errors..."
set -e
set -x

echo "Building varnish container ..."
docker build --build-arg version=${VARNISH_VERSION} -f Dockerfile.varnish-core                     -t docker.artifactory.futurenet.com/tjackson02/varnish:${VARNISH_VERSION} .
docker build --build-arg version=${VARNISH_VERSION} --build-arg mode=edge    -f Dockerfile.varnish -t docker.artifactory.futurenet.com/tjackson02/evha-edge-varnish:${IMAGE_TAG} .
docker build --build-arg version=${VARNISH_VERSION} --build-arg mode=origin  -f Dockerfile.varnish -t docker.artifactory.futurenet.com/tjackson02/evha-origin-varnish:${IMAGE_TAG} .


echo "Building envoy containers ..."
docker build --build-arg mode=edge   -f Dockerfile.envoy -t docker.artifactory.futurenet.com/tjackson02/evha-edge-envoy:${IMAGE_TAG} .
docker build --build-arg mode=origin -f Dockerfile.envoy -t docker.artifactory.futurenet.com/tjackson02/evha-origin-envoy:${IMAGE_TAG} .

echo "Building test-app container ..."
cd  src/service
docker build -t docker.artifactory.futurenet.com/tjackson02/evha-test-app:${IMAGE_TAG} .
cd -


echo "Pushing containers..."

docker push docker.artifactory.futurenet.com/tjackson02/evha-edge-varnish:${IMAGE_TAG}
docker push docker.artifactory.futurenet.com/tjackson02/evha-origin-varnish:${IMAGE_TAG}
docker push docker.artifactory.futurenet.com/tjackson02/evha-edge-envoy:${IMAGE_TAG}
docker push docker.artifactory.futurenet.com/tjackson02/evha-origin-envoy:${IMAGE_TAG}
docker push docker.artifactory.futurenet.com/tjackson02/evha-test-app:${IMAGE_TAG}


echo "------"
echo "Fin..."