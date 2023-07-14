#!/bin/bash
push_flag='false'
registry='avinashyadavpuresoftware/'     # e.g. 'descartesresearch/'
DOCKER_PLATFORMS='linux/amd64,linux/arm64'
print_usage() {
  printf "Usage: docker_build.sh [-p] [-r REGISTRY_NAME]\n"
}

while getopts 'pr:' flag; do
  case "${flag}" in
    p) push_flag='true' ;;
    r) registry="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

docker run -it --rm --privileged tonistiigi/binfmt --install all
docker login -u avinashyadavpuresoftware -p 958956b2-e8a6-4461-82e8-451eb8433325
docker buildx create --use --name mybuilder
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-dbt" ../utilities/tools.descartes.teastore.database/ --push .
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-kieker-rabbitmqt" ../utilities/tools.descartes.teastore.kieker.rabbitmq/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-baset" ../utilities/tools.descartes.teastore.dockerbase/ --push
perl -i -pe's|.*FROM descartesresearch/|FROM '"${registry}"'|g' ../services/tools.descartes.teastore.*/Dockerfile
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-registryt" ../services/tools.descartes.teastore.registry/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-persistencet" ../services/tools.descartes.teastore.persistence/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-imaget" ../services/tools.descartes.teastore.image/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-webuit" ../services/tools.descartes.teastore.webui/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-autht" ../services/tools.descartes.teastore.auth/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-recommendert" ../services/tools.descartes.teastore.recommender/ --push
docker buildx rm mybuilder
#perl -i -pe's|.*FROM '"${registry}"'|FROM descartesresearch/|g' ../services/tools.descartes.teastore.*/Dockerfile
