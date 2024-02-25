#!/usr/bin/env bash

# shellcheck disable=SC2046,SC2086,SC2317

# set -euo pipefail

TLD="$(git rev-parse --show-toplevel)"
ENV_FILE="${TLD}/.env"
[[ -f "${ENV_FILE}" ]] && export $(grep -v '^#' ${ENV_FILE} | xargs)
export NODE_OPTIONS="--openssl-legacy-provider"

usage() { echo "Usage: task install -- <yarn|mega-linter|pre-commit>"; }

if [ $# -ne 1 ]; then
	usage
	exit 0
else
	args=$1
fi

# TODO: transpile bootstrap
main() {
	case "$args" in
		pre-commit)
			pre-commit install
			;;
		""|*)
			usage
			;;
	esac
}
main "$@"

exit 0
