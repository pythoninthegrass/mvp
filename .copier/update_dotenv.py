#!/usr/bin/env python3

from pathlib import Path
import json
import os
import sys

# Update the .env file with the answers from the .copier-answers.yml file
# without using Jinja2 templates in the .env file, this way the code works as is
# without needing Copier, but if Copier is used, the .env file will be updated
def main():
    root_path = Path(__file__).parent.parent
    answers_path = root_path / ".copier-answers.yml"
    
    if not answers_path.exists():
        print(f"Answers file not found: {answers_path}")
        return
    
    try:
        with open(answers_path, "r") as f:
            answers_content = f.read()
            # Remove YAML comments and load as JSON
            clean_content = "\n".join([line for line in answers_content.split("\n") if not line.strip().startswith("#")])
            answers = json.loads(clean_content)
    except Exception as e:
        print(f"Error loading answers: {e}")
        return
    
    env_path = root_path / ".env.example"
    if not env_path.exists():
        print(f"Environment file not found: {env_path}")
        return
    
    env_content = env_path.read_text()
    lines = []
    for line in env_content.splitlines():
        if not line.strip() or line.strip().startswith("#"):
            lines.append(line)
            continue
            
        for key, value in answers.items():
            upper_key = key.upper()
            if "=" in line and line.split("=", 1)[0].strip() == upper_key:
                if isinstance(value, str) and " " in value:
                    content = f"{upper_key}={value!r}"
                else:
                    content = f"{upper_key}={value}"
                new_line = line.replace(line, content)
                lines.append(new_line)
                break
        else:
            lines.append(line)
    
    # Create the .env file from .env.example with the updated values
    new_env_path = root_path / ".env"
    new_env_path.write_text("\n".join(lines))
    print(f"Updated environment file: {new_env_path}")

if __name__ == "__main__":
    main()
