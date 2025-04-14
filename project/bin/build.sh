#!/usr/bin/env bash

set -euo pipefail

TLD="$(git rev-parse --show-toplevel)"
WORK_DIR="${TLD}"
ENV_FILE="${TLD}/.env"
[[ -f "${ENV_FILE}" ]] && export $(grep -v '^#' ${ENV_FILE} | xargs)
REGISTRY=${REGISTRY:-}
USER_NAME=${USER_NAME:-}
VERSION=${VERSION:-latest}

# Check that buildx is installed
if ! docker buildx version >/dev/null 2>&1; then
	echo "https://github.com/docker/buildx#installing"
	echo "docker buildx is not available. Please install it first. Exiting..."
	exit 1
fi

get_platform() {
	local os arch

	os=$(uname -s | tr '[:upper:]' '[:lower:]')
	arch=$(uname -m)

	case "${os}" in
		linux|darwin)
			os="linux"
			;;
		*)
			echo "Unsupported OS: ${os}" >&2
			exit 1
			;;
	esac

	case "${arch}" in
		x86_64)
			arch="amd64"
			;;
		aarch64|arm64)
			arch="arm64/v8"
			;;
		armv7l)
			arch="arm/v7"
			;;
		*)
			echo "Unsupported architecture: ${arch}" >&2
			exit 1
			;;
	esac

	echo "${os}/${arch}"
}

build() {
	local dockerfile
	local platform
	local registry
	local service
	local tag
	local user_name
	local version
	local work_dir

	dockerfile="$1"
	service="$2"
	work_dir="${WORK_DIR}"
	platform="${PLATFORM:-$(get_platform)}"
	registry="${REGISTRY}"
	user_name="${USER_NAME}"
	version="${VERSION}"

	if [[ -n "${registry}" && -n "${user_name}" ]]; then
		tag="${registry}/${user_name}/${service}:${version}"
	else
		tag="${service}:${version}"
	fi

	if [[ "${platform}" != "$(get_platform)" ]]; then
		(
			cd "${work_dir}"
			docker buildx build \
				--platform="${platform}" \
				-f "${dockerfile}" \
				--build-arg VERSION="${version}" \
				-t "${tag}" \
				--load \
				.
		)
	else
		(
			cd "${work_dir}"
			docker build \
				-f "${dockerfile}" \
				--build-arg VERSION="${version}" \
				-t "${tag}" \
				.
		)
	fi
}

usage() {
	echo "Usage: $(basename "$0") [OPTIONS] <dockerfile> <service>"
	echo "Options:"
	echo "  -p, --platform PLATFORM    Specify the target platform (e.g., linux/amd64)"
	echo "  -h, --help                 Display this help message"
}

# TODO: qa `getopts`
main() {
	# local positional=()

	# while [[ $# -gt 0 ]]; do
	# 	case "$1" in
	# 		-p|--platform)
	# 			PLATFORM="$2"
	# 			shift 2
	# 			;;
	# 		-h|--help)
	# 			usage
	# 			exit 0
	# 			;;
	# 		build)
	# 			shift
	# 			;;
	# 		*)
	# 			positional+=("$1")
	# 			shift
	# 			;;
	# 	esac
	# done

	# set -- "${positional[@]}"

	while getopts ":hp:-:" opt; do
		case ${opt} in
			h)
				usage
				exit 0
				;;
			p)
				PLATFORM="$OPTARG"
				;;
			-)
				case "${OPTARG}" in
					help)
						usage
						exit 0
						;;
					platform)
						PLATFORM="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
						;;
					*)
						echo "Invalid option: --${OPTARG}" >&2
						usage
						exit 1
						;;
				esac
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				usage
				exit 1
				;;
			:)
				echo "Option -$OPTARG requires an argument." >&2
				usage
				exit 1
				;;
		esac
	done
	shift $((OPTIND -1))

	if [[ $# -lt 2 ]]; then
		echo "Error: Missing required arguments." >&2
		usage
		exit 1
	fi

	local dockerfile="$1"
	local service="$2"

	build "$dockerfile" "$service"
}

main "$@"
