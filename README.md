<!-- markdownlint-disable MD022 MD031 MD036 MD032 -->
# mvp

<!-- !["It's dangerous to go alone! Take this."](static/image.jpg) -->
<!-- <img src="https://user-images.githubusercontent.com/4097471/144654508-823c6e31-5e10-404c-9f9f-0d6b9d6ce617.jpg" width="300"> -->

**minimum viable python**

## Summary
Sets up a new development environment for a Mac or Linux (i.e., UNIX) box.

**Table of Contents**
* [mvp](#mvp)
  * [Summary](#summary)
  * [Setup](#setup)
    * [Minimum requirements](#minimum-requirements)
    * [Recommended requirements](#recommended-requirements)
  * [Development](#development)
    * [Devbox](#devbox)
    * [Taskfile](#taskfile)
    * [Tilt](#tilt)
  * [TODO](#todo)
  * [Further Reading](#further-reading)

## Setup
### Minimum requirements
* [Python 3.11](https://www.python.org/downloads/)

### Recommended requirements
* [devbox](https://www.jetpack.io/devbox/docs/quickstart/)
* [task](https://taskfile.dev/#/installation)

## Development
### Devbox
Devbox takes care of setting up a dev environment automatically. 

Under the hood it uses [Nix Package Manager](https://search.nixos.org/packages).

```bash
# install devbox
./bootstrap

# enter dev environment w/deps
devbox shell

# run repl
python

# exit dev environment
exit

# run tests
devbox run test
```

### Taskfile
```bash
λ task
task: Available tasks for this project:
* checkbash:                Check bash scripts
* default:                  Default task
* format:                   Run formatters
* install:                  Install project dependencies
* install-devbox:           Install devbox
* lint:                     Run linters
* pre-commit:               Run pre-commit hooks
* pyclean:                  Remove .pyc and __pycache__
* test:                     Run tests
* docker:build:             Build the docker image                                                     (aliases: docker:build)
* docker:down:              Stop and remove containers, networks, and volumes with docker compose      (aliases: docker:down)
* docker:exec:              Shell into a running container                                             (aliases: docker:exec)
* docker:login:             Login to the container registry                                            (aliases: docker:login)
* docker:logs:              Follow the logs of a running container                                     (aliases: docker:logs)
* docker:net:               Create docker network                                                      (aliases: docker:net)
* docker:prune:             Prune docker                                                               (aliases: docker:prune)
* docker:push:              Push the docker image to the registry                                      (aliases: docker:push)
* docker:stop:              Stop the project with docker compose                                       (aliases: docker:stop)
* docker:up:                Start the project with docker compose                                      (aliases: docker:up)
* docker:vol:               Create docker volume                                                       (aliases: docker:vol)
* poetry:add-pypi:          Add test-pypi repository                                                   (aliases: poetry:add-pypi)
* poetry:build:             Build the poetry bin                                                       (aliases: poetry:build)
* poetry:bump-semver:       Bump the project semantic version                                          (aliases: poetry:bump-semver)
* poetry:default:           Default task                                                               (aliases: poetry:default, poetry, poetry)
* poetry:export-reqs:       Export requirements.txt                                                    (aliases: poetry:export-reqs)
* poetry:install:           Install project dependencies                                               (aliases: poetry:install)
* poetry:publish:           Publish the poetry bin                                                     (aliases: poetry:publish)
* poetry:update-deps:       Update dependencies                                                        (aliases: poetry:update-deps)
```

### Tilt
```bash
minikube start --memory=2048 --cpus=2 --kubernetes-version=v1.28.3 -p minikube
git clone https://github.com/tilt-dev/tilt-example-python
cd tilt-example-python/3-recommended
tilt up
minikube stop
minikube delete
rm -rf tilt-example-python
```

## TODO
* [Open Issues](https://github.com/pythoninthegrass/mvp/issues)
* QA [Ansible playbook](ansible/playbook.yml)
  * Test
    * macOS
    * Ubuntu
* Write boilerplate pytest tests
* CI/CD

## Further Reading
* [python](https://www.python.org/)
* [asdf](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf)
* [poetry](https://python-poetry.org/docs/)
* [docker-compose](https://docs.docker.com/compose/install/)
* [pre-commit hooks](https://pre-commit.com/)
