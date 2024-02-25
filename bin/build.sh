#!/usr/bin/env bash

# shellcheck disable=SC2046,SC2086,SC2317

# set -euo pipefail

TLD="$(git rev-parse --show-toplevel)"
ENV_FILE="${TLD}/app/.env"
[[ -f "${ENV_FILE}" ]] && export $(grep -v '^#' ${ENV_FILE} | xargs)
PLATFORM="linux/amd64"
REGISTRY=${REGISTRY:-docker.io}
USER_NAME=${USER_NAME:-pythoninthegrass}
SERVICE=${SERVICE:-mvp}

# check that buildx is installed
if ! docker buildx version >/dev/null 2>&1; then
	echo "https://github.com/docker/buildx#installing"
	echo "docker buildx is not available. Please install it first. Exiting..."
	exit 1
fi

# docker build
build() {
	FILENAME=$1
	SERVICE=$2
	docker buildx build \
		--platform="${PLATFORM}" \
		-f "${FILENAME}" \
		-t "${REGISTRY}/${USER_NAME}/${SERVICE}" \
		--load .
}

main() {
	case "$1" in
		build)
			build "$2" "$3"
			;;
		""|*)
			echo "USAGE: $(basename $0) <build> <Dockerfile> <service>"
			;;
	esac
}
main "$@"

exit 0
