#!/usr/bin/make -f

.DEFAULT_GOAL		:= help

.ONESHELL:

# ENV VARS
export SHELL 		:= $(shell which sh)
export PY_VER		:= "3.12.0"
export UNAME 		:= $(shell uname -s)

# MULTIPASS
export NAME			:= testvm
export IMAGE		:= 22.04
export CPU			:= 4
export DISK			:= 5G
export MEM			:= 3G

# check commands and OS
ifeq ($(UNAME), Darwin)
	export XCODE := $(shell xcode-select --install >/dev/null 2>&1; echo $$?)
endif

ifeq ($(UNAME), Darwin)
	export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK := 1
endif

export ASDF := $(shell command -v asdf 2>/dev/null)
export BREW := $(shell command -v brew 2>/dev/null)
export DEVBOX := $(shell command -v devbox 2>/dev/null)
export GIT := $(shell command -v git 2>/dev/null)
export PRE_COMMIT := $(shell command -v pre-commit 2>/dev/null)
export TASK := $(shell command -v task 2>/dev/null)

ifeq ($(shell command -v git >/dev/null 2>&1; echo $$?), 0)
	export GIT := $(shell which git)
endif

ifeq ($(shell command -v python3 >/dev/null 2>&1; echo $$?), 0)
	export PYTHON := $(shell which python3)
endif

ifeq ($(shell command -v pip >/dev/null 2>&1; echo $$?), 0)
	export PIP := $(shell which pip3)
endif

ifeq ($(shell command -v ansible >/dev/null 2>&1; echo $$?), 0)
	export ANSIBLE := $(shell which ansible)
endif

ifneq (,$(wildcard /etc/os-release))
	include /etc/os-release
endif

# colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

# targets
.PHONY: all
all: help asdf xcode brew devbox pre-commit task ## run all targets

xcode: ## install xcode command line tools
	if [ "${UNAME}" = "Darwin" ] && [ -n "${XCODE}" ]; then \
		echo "Installing Xcode command line tools..."; \
		xcode-select --install; \
	elif [ "${UNAME}" = "Darwin" ] && [ "${XCODE}" -eq 1 ]; then \
		echo "xcode already installed."; \
	else \
		echo "xcode not supported."; \
	fi

homebrew: ## install homebrew
	if [ "${UNAME}" = "Darwin" ] && [ -n "${BREW}" ]; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	elif [ "${UNAME}" = "Darwin" ] && [ ! -z "${BREW}" ]; then \
		echo "Homebrew already installed."; \
	else \
		echo "brew not supported"; \
	fi

devbox: ## install devbox
	@if [ -z "${DEVBOX}" ]; then \
		echo "Installing devbox..."; \
		curl -fsSL https://get.jetpack.io/devbox | bash; \
	else \
		echo "devbox already installed."; \
	fi

asdf: xcode ## install asdf
ifeq ($(UNAME), Darwin)
	@if [ -z "${ASDF}" ]; then \
		echo "Installing asdf..."; \
		git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION}; \
		echo "To use asdf, add the following to your shell rc (.bashrc/.zshrc):"; \
		echo "export PATH=\"$$HOME/.asdf/shims:$$PATH\""; \
		echo ". $$HOME/.asdf/asdf.sh"; \
		echo ". $$HOME/.asdf/completions/asdf.bash"; \
	else \
		echo "asdf already installed."; \
	fi

git: ## install git
	if [ -n "${GIT}" ]; then \
		echo "git already installed."; \
		exit 0; \
	fi
	if [ "${UNAME}" = "Darwin" ] && [ -n "${BREW}" ]; then \
		brew install git; \
	elif [ "${ID}" = "ubuntu" ] || [ "${ID_LIKE}" = "debian" ]; then \
		sudo apt install -y git; \
	else \
		echo "git already installed"; \
	fi

python: ## install system python
	if [ -n "${PYTHON}" ]; then \
		echo "python already installed."; \
		exit 0; \
	fi
	if [ "${UNAME}" = "Darwin" ] && [ -z "${PYTHON}" ]; then \
		brew install python; \
	elif [ "${ID}" = "ubuntu" ] || [ "${ID_LIKE}" = "debian" ]; then \
		sudo apt install -y python3; \
	fi

pip: python ## install pip
	if [ -n "${PIP}" ]; then \
		echo "pip already installed."; \
		exit 0; \
	fi
	if [ "${UNAME}" = "Darwin" ] && [ -z "${PYTHON})" ]; then \
		brew install python; \
	elif [ "${ID}" = "ubuntu" ] || [ "${ID_LIKE}" = "debian" ] && [ -z "${PIP}" ]; then \
		sudo apt install -y python3-pip; \
	else \
		echo "pip install not supported on os"; \
	fi

install: xcode asdf brew devbox pre-commit task ## install dependencies

list:
	@echo "${YELLOW}Listing instances${RESET}"
	multipass list

info: ## show info about the instance
	@echo "${YELLOW}Showing info about the instance${RESET}"
	multipass info --format yaml "${NAME}"

shell: ## open a shell in the instance
	@echo "${YELLOW}Opening a shell in the instance${RESET}"
	multipass shell "${NAME}"

mount: ## mount volume in instance
	@echo "${YELLOW}Mounting the instance${RESET}"
	multipass mount $(shell pwd) "${NAME}":~/git/$(shell basename $(shell pwd))

stop: ## stop the instance
	@echo "${YELLOW}Stopping the instance${RESET}"
	multipass stop "${NAME}"

start: ## start the instance
	@echo "${YELLOW}Starting the instance${RESET}"
	multipass start "${NAME}"

delete: stop ## delete the instance
	@echo "${YELLOW}Deleting the instance${RESET}"
	multipass delete "${NAME}"

purge: ## purge all instances
	@echo "${YELLOW}Purging all instances${RESET}"
	multipass purge
# ! MULTIPASS END

run: ## run ansible playbook
	@echo "${YELLOW}Running ansible playbook${RESET}"
	#!/usr/bin/env bash
	# set -euxo pipefail
	multipass exec "${NAME}" -- \
		ansible-playbook \
			/home/ubuntu/apt_lab_tf/ansible/playbook.yml \
			--tags qa \
			-vvv

install: xcode homebrew git python pip ansible ## install dependencies

release: ## release package
	[ ! -z "${POETRY}" ] && poetry build

test: ## run tests
	[ ! -z "${POETRY}" ] && poetry run pytest

help: ## show this help
	@echo ''
	@echo 'Usage:'
	@echo '    ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
