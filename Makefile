#!/usr/bin/make -f

.DEFAULT_GOAL := help

.ONESHELL:

# ENV VARS
export SHELL := $(shell which sh)
export ARCH := $(shell arch)
export UNAME := $(shell uname -s)
export ASDF_VERSION := v0.14.1

# check commands and OS
ifeq ($(UNAME), Darwin)
	export XCODE := $(shell xcode-select -p 2>/dev/null)
	export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK := 1
else ifeq ($(UNAME), Linux)
	include /etc/os-release
endif

# colors
GREEN := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE := $(shell tput -Txterm setaf 7)
CYAN := $(shell tput -Txterm setaf 6)
RESET := $(shell tput -Txterm sgr0)

# Usage: $(call check_bin,command_name)
define check_bin
	! command -v $(1) >/dev/null 2>&1
endef

# Usage: $(call brew_install,package_name)
# For packages where binary name differs from package name, add a mapping in the case statement
define brew_install
	@if [ "${UNAME}" = "Darwin" ] || [ "${UNAME}" = "Linux" ]; then \
		binary_name=""; \
		case "$(1)" in \
			"go-task") binary_name="task" ;; \
			*) binary_name="$(1)" ;; \
		esac; \
		if [ -z "$(call check_bin,$$binary_name)" ]; then \
			echo "Installing $(1)..."; \
			brew install $(1); \
		else \
			echo "$(1) already installed."; \
		fi \
	else \
		echo "$(1) not supported."; \
	fi
endef

# targets
.PHONY: all
all: help install ## run all targets

install: xcode asdf brew devbox jq pre-commit sccache task ## install dependencies

xcode: ## install xcode command line tools
ifeq ($(UNAME), Darwin)
	@if [ -z "${XCODE}" ]; then \
		echo "Installing Xcode command line tools..."; \
		xcode-select --install; \
	else \
		echo "xcode already installed."; \
	fi
else
	@echo "xcode not supported."
endif

brew: xcode ## install homebrew
ifeq ($(UNAME), Darwin)
	@if $(call check_bin,brew); then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "brew already installed."; \
	fi
else ifeq ($(UNAME), Linux)
	@if [ "$(ARCH)" = "aarch64" ]; then \
		echo "Homebrew on Linux is not supported on ARM processors."; \
	elif $(call check_bin,brew) && [ "$(ID_LIKE)" = "debian" ]; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "brew already installed."; \
	fi
else
	@echo "brew not supported."
endif

asdf: xcode ## install asdf
	@if $(call check_bin,asdf); then \
		echo "Installing asdf..."; \
		git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION}; \
		echo "To use asdf, add the following to your shell rc (.bashrc/.zshrc):"; \
		echo "export PATH=\"$$HOME/.asdf/shims:$$PATH\""; \
		echo ". $$HOME/.asdf/asdf.sh"; \
		echo ". $$HOME/.asdf/completions/asdf.bash"; \
	else \
		echo "asdf already installed."; \
	fi

devbox: ## install devbox
	@if $(call check_bin,devbox); then \
		echo "Installing devbox..."; \
		curl -fsSL https://get.jetpack.io/devbox | bash; \
	else \
		echo "devbox already installed."; \
	fi

jq: brew ## install jq
	$(call brew_install,jq)

pre-commit: brew ## install pre-commit
	$(call brew_install,pre-commit)

sccache: brew ## install sccache
	$(call brew_install,sccache)

task: ## install taskfile
ifeq ($(UNAME), Darwin)
	$(call brew_install,go-task)
else ifeq ($(UNAME), Linux)
	@if $(call check_bin,task); then \
		echo "Installing task..."; \
		sh -c "$$(curl -sl https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin; \
	else \
		echo "task already installed."; \
	fi
else
	@echo "task installation not supported on this OS."
endif

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
