#!/usr/bin/env python3
"""
This script updates the .env file with values from the Copier answers.
It allows the .env file to be a regular file (not a template) that works with or without Copier.
"""

from pathlib import Path
import json
import yaml

# Update the .env file with the answers from the .copier-answers.yml file
# without using Jinja2 templates in the .env file, this way the code works as is
# without needing Copier, but if Copier is used, the .env file will be updated
root_path = Path(__file__).parent.parent
answers_path = root_path / ".copier-answers.yml"

# Load the answers from YAML format
with open(answers_path, "r") as f:
    answers_yaml = f.read()
    # Convert YAML to Python dict
    answers = yaml.safe_load(answers_yaml)

env_path = root_path / ".env"
if not env_path.exists():
    env_example_path = root_path / ".env.example"
    if env_example_path.exists():
        with open(env_example_path, "r") as f:
            env_content = f.read()
    else:
        env_content = ""
else:
    with open(env_path, "r") as f:
        env_content = f.read()

# Update the .env file
lines = []
for line in env_content.splitlines():
    line_updated = False
    for key, value in answers.items():
        upper_key = key.upper()
        if line.startswith(f"{upper_key}="):
            if isinstance(value, str) and " " in value:
                content = f'{upper_key}="{value}"'
            else:
                content = f"{upper_key}={value}"
            lines.append(content)
            line_updated = True
            break
    if not line_updated:
        lines.append(line)

# Write the updated .env file
with open(env_path, "w") as f:
    f.write("\n".join(lines))

print(f"Updated {env_path} with values from Copier answers.")
