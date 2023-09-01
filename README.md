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
  * [TODO](#todo)
  * [Further Reading](#further-reading)

## Setup

* Install
  * make
    * [Debian/Ubuntu](https://www.gnu.org/software/make/)
    * [macOS](https://www.freecodecamp.org/news/install-xcode-command-line-tools/)
  * [editorconfig](https://editorconfig.org/)
  * [wsl](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)

## Quickstart

```bash
# install dependencies (e.g., git, ansible, etc.)
./bootstrap install

# install tools and runtimes (cf. xcode, brew, asdf, poetry, etc.)
./bootstrap <run|run-dev>   # dev only runs plays w/tags and is verbose

# install git hooks
./bootstrap install-precommit

# update git hooks
./bootstrap update-precommit
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
