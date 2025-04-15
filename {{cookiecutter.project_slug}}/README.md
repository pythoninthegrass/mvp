# {{ cookiecutter.project_name }}

{{ cookiecutter.project_short_description }}

## Summary

Sets up a new development environment for a Mac or Linux (i.e., UNIX) box.

**Table of Contents**

* [{{ cookiecutter.project_name }}](#{{ cookiecutter.project_name | slugify }})
  * [Summary](#summary)
  * [Setup](#setup)
    * [Minimum requirements](#minimum-requirements)
    * [Recommended requirements](#recommended-requirements)
  * [Development](#development)
    * [Devbox](#devbox)
    * [Taskfile](#taskfile)
{%- if cookiecutter.command_line_interface != "No command-line interface" %}
    * [CLI Usage](#cli-usage)
{%- endif %}
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
# install base dependencies
make install

# install devbox
task install-devbox

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
```

{% if cookiecutter.command_line_interface != "No command-line interface" -%}
### CLI Usage

After installation, you can use the `{{ cookiecutter.project_slug }}` command:

```bash
# Show help
{{ cookiecutter.project_slug }} --help

# Run the main command
{{ cookiecutter.project_slug }} run
```
{%- endif %}

## TODO

* [Open Issues](https://github.com/{{ cookiecutter.github_username }}/{{ cookiecutter.project_slug }}/issues)
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
