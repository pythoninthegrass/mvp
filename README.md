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
  * [Quickstart](#quickstart)
  * [Development](#development)
    * [Makefile](#makefile)
    * [Taskfile](#taskfile)
    * [Devbox](#devbox)
  * [TODO](#todo)
  * [Further Reading](#further-reading)

## Setup
* Minimum requirements
  * [Python 3.11](https://www.python.org/downloads/)
* Dev dependencies
  * make
    * [Linux](https://www.gnu.org/software/make/)
    * [macOS](https://www.freecodecamp.org/news/install-xcode-command-line-tools/)
  * [editorconfig](https://editorconfig.org/)
  * [wsl](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)

## Quickstart
* Install python and tooling
    ```bash
    # install python and dependencies (e.g., git, ansible, etc.)
    ./bootstrap install
    ```

## Development
### Makefile
```bash
# install all repo dependcies
make install

# install specific repo dependencies
make <xcode|asdf|brew|devbox|pre-commit|task>
```

### Taskfile
```bash
λ task
task: [default] task --list
task: Available tasks for this project:
* checkbash:            Check bash scripts
* export-reqs:          Export requirements.txt
* install:              Install project dependencies
* pre-commit:           Run pre-commit hooks
* run:                  Run the playbook
* run-dev:              Run the playbook with tags and debug
* update-deps:          Update dependencies
* docker:build:         Build the docker image
* docker:down:          Stop and remove containers, networks, and volumes with docker compose
* docker:exec:          Shell into a running container               
* docker:logs:          Follow the logs of a running container               
* docker:net:           Create docker network 
* docker:prune:         Prune docker          
* docker:push:          Push the docker image to the registry                
* docker:stop:          Stop the project with docker compose                  
* docker:up:            Start the project with docker compose                  
* docker:vol:           Create docker volume  
```

### Devbox
I.e., [Nix Package Manager](https://search.nixos.org/packages)
```bash
# enter dev environment
devbox shell

# run individual app
python <sign_jwt|meetup_query|slackbot|main>.py

# exit dev environment
exit

# run standalone server
devbox run start

# run tests
devbox run test
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
