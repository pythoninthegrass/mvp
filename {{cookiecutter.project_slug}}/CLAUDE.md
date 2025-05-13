# {{cookiecutter.project_name}} Project Reference

## General Instructions

- Minimize inline comments
- Retain tabs, spaces, and encoding
- Fix linting errors before saving files.
  - Respect `.markdownlint.jsonc` rules for all markdown files
- If under 50 lines of code (LOC), print the full function or class
- If the token limit is close or it's over 50 LOC, print the line numbers and avoid comments altogether
- Explain as much as possible in the chat unless asked to annotate (i.e., docstrings, newline comments, etc.)

## Build, Lint, and Test Commands

- Full test suite: `uv run pytest` or `task test`
- Single test: `uv run pytest tests/test_filename.py::test_function_name`
- Linting: `uv run ruff check --fix --respect-gitignore` or `task lint`
- Formatting: `uv run ruff format --respect-gitignore` or `task format`
- Check dependencies: `uv run deptry .` or `task deptry`
- Pre-commit hooks: `pre-commit run --all-files` or `task pre-commit`

## Code Style Guidelines

- **Formatting**: 4 spaces, 130-char line limit, LF line endings
- **Imports**: Ordered by type, combined imports when possible
- **Naming**: snake_case functions/vars, PascalCase classes, UPPERCASE constants
- **Type Hints**: Use Optional for nullable params, pipe syntax for Union
- **Error Handling**: Specific exception types, descriptive error messages
- **File Structure**: Core logic in app/core/, utilities in app/utils/
- **Docstrings**: Use double quotes for docstrings
- **Tests**: Files in tests/, follow test_* naming convention
