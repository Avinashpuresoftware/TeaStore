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
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-db" ../utilities/tools.descartes.teastore.database/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-kieker-rabbitmq" ../utilities/tools.descartes.teastore.kieker.rabbitmq/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-base" ../utilities/tools.descartes.teastore.dockerbase/ --push
perl -i -pe's|.*FROM descartesresearch/|FROM '"${registry}"'|g' ../services/tools.descartes.teastore.*/Dockerfile
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-registry" ../services/tools.descartes.teastore.registry/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-persistence" ../services/tools.descartes.teastore.persistence/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-image" ../services/tools.descartes.teastore.image/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-webui" ../services/tools.descartes.teastore.webui/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-auth" ../services/tools.descartes.teastore.auth/ --push
docker buildx build --platform ${DOCKER_PLATFORMS} -t "${registry}teastore-recommender" ../services/tools.descartes.teastore.recommender/ --push
docker buildx rm mybuilder
#perl -i -pe's|.*FROM '"${registry}"'|FROM descartesresearch/|g' ../services/tools.descartes.teastore.*/Dockerfile
