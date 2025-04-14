from datetime import datetime
from typing import Dict, Any

from jinja2.ext import Extension


class CurrentYearExtension(Extension):
    """
    Jinja extension that adds a {{ current_year }} variable containing the current year.
    """

    def __init__(self, environment):
        super().__init__(environment)
        environment.globals["current_year"] = str(datetime.now().year)


class GitExtension(Extension):
    """
    Jinja extension that adds support for filters:
    - git_user_name: returns the default user name from git config
    - git_user_email: returns the default user email from git config
    """

    def __init__(self, environment):
        super().__init__(environment)

        try:
            import subprocess

            stdout = subprocess.check_output(
                ["git", "config", "--get", "user.name"],
                text=True,
                stderr=subprocess.DEVNULL,
            ).strip()
            environment.filters["git_user_name"] = lambda default="": stdout or default
        except (subprocess.SubprocessError, FileNotFoundError):
            environment.filters["git_user_name"] = lambda default="": default

        try:
            import subprocess

            stdout = subprocess.check_output(
                ["git", "config", "--get", "user.email"],
                text=True,
                stderr=subprocess.DEVNULL,
            ).strip()
            environment.filters["git_user_email"] = lambda default="": stdout or default
        except (subprocess.SubprocessError, FileNotFoundError):
            environment.filters["git_user_email"] = lambda default="": default


class SlugifyExtension(Extension):
    """
    Jinja extension that adds a filter:
    - slugify: to convert "The text" into "the-text" or "the_text" if underscore=True
    """

    def __init__(self, environment):
        super().__init__(environment)

        def slugify(text, underscore=False):
            import re
            import unicodedata

            text = unicodedata.normalize("NFKD", text)
            text = text.encode("ascii", "ignore").decode("ascii")
            text = text.lower()
            text = re.sub(r"[^a-z0-9]+", "_" if underscore else "-", text)
            text = re.sub(r"[-_]+", "_" if underscore else "-", text)
            text = text.strip("_" if underscore else "-")
            return text

        environment.filters["slugify"] = slugify
