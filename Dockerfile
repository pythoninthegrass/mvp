# syntax=docker/dockerfile:1.7.0

# full semver just for python base image
ARG PYTHON_VERSION=3.11.11

FROM python:${PYTHON_VERSION}-slim-bullseye AS builder

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# update apt-get repos and install dependencies
RUN apt-get -qq update \
    && apt-get -qq install --no-install-recommends -y \
    curl \
    gcc \
    libpq-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# pip env vars
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV PIP_DEFAULT_TIMEOUT=100

# poetry env vars
ENV POETRY_HOME="/opt/poetry"
ENV POETRY_VERSION=1.8.5
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
ENV POETRY_NO_INTERACTION=1

# path
ENV VENV="/opt/venv"
ENV PATH="$POETRY_HOME/bin:$VENV/bin:$PATH"

# create app directory and set as working directory
WORKDIR /app

# copy dependencies
COPY requirements.txt requirements.txt

# install poetry and dependencies
RUN python -m venv $VENV \
    && . "${VENV}/bin/activate" \
    && python -m pip install "poetry==${POETRY_VERSION}" \
    && python -m pip install -r requirements.txt

FROM python:${PYTHON_VERSION}-slim-bullseye AS dev

# setup path
ENV VENV="/opt/venv"
ENV PATH="${VENV}/bin:${VENV}/lib/python${PYTHON_VERSION}/site-packages:/usr/local/bin:${HOME}/.local/bin:/bin:/usr/bin:/usr/share/doc:$PATH"

# standardise on locale, don't generate .pyc, enable tracebacks on seg faults
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# workers per core
# https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker/blob/master/README.md#web_concurrency
ENV WEB_CONCURRENCY=2

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# install dependencies
RUN apt-get -qq update \
    && apt-get -qq install --no-install-recommends -y \
    bat \
    curl \
    dpkg \
    git \
    iputils-ping \
    lsof \
    make \
    p7zip \
    perl \
    shellcheck \
    sudo \
    tldr \
    tree \
    && rm -rf /var/lib/apt/lists/*

# setup standard non-root user for use downstream
ARG USER_NAME=appuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USER_NAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USER_NAME

RUN echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

# copy virtual environment from builder stage
COPY --from=builder --chown=${USER_NAME}:${USER_GROUP} $VENV $VENV

# qol: tooling
RUN <<EOF
#!/usr/bin/env bash
# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install
EOF

# switch to non-root user
USER $USER_NAME

# qol: .bashrc
RUN tee -a "$HOME/.bashrc" <<"EOF"

# shared history
HISTFILE=/var/tmp/.bash_history
HISTFILESIZE=100
HISTSIZE=100

stty -ixon

# fzf
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

# asdf
# https://asdf-vm.com/guide/getting-started.html
export ASDF_DIR="$HOME/.asdf"
[[ -f "${ASDF_DIR}/asdf.sh" ]] && . "${ASDF_DIR}/asdf.sh"

# homebrew
export BREW_PREFIX="/home/linuxbrew/.linuxbrew/bin"
[[ -f "${BREW_PREFIX}/brew" ]] && eval "$(${BREW_PREFIX}/brew shellenv)"

# aliases
alias ..='cd ../'
alias ...='cd ../../'
alias ll='ls -la --color=auto'

EOF

FROM dev AS runner

# change working directory
WORKDIR /app

# $PATH
ENV PATH=$VENV_PATH/bin:$HOME/.local/bin:$PATH

# port needed by app
EXPOSE 8000

# run container indefinitely
CMD ["sleep", "infinity"]

# metadata
LABEL org.opencontainers.image.title="python-class"
