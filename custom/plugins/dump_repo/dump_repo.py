import os
import json
import subprocess
import pkg_resources
from pathlib import Path
import typer
import tiktoken
import pyperclip

app = typer.Typer()

def install_package(package: str):
    """Install a Python package using pip."""
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

def check_and_install_packages():
    """Check for required packages and install them if missing."""
    required = {'tiktoken', 'pyperclip'}
    installed = {pkg.key for pkg in pkg_resources.working_set}
    missing = required - installed

    if missing:
        print(f"Missing packages detected: {missing}. Installing them...")
        for package in missing:
            install_package(package)
        print("All required packages are now installed.")

check_and_install_packages()

def read_gitignore_patterns(folder: str):
    """Read .gitignore patterns from the specified folder and add additional patterns."""
    gitignore_patterns = ['.conda', '__pycache__']  # Add these patterns by default
    gitignore_path = Path(folder) / '.gitignore'
    if gitignore_path.exists():
        with open(gitignore_path, 'r') as f:
            gitignore_patterns.extend([line.strip() for line in f if line.strip() and not line.startswith('#')])
    return gitignore_patterns

def is_excluded(path: str, gitignore_patterns: list):
    """Check if the given path matches any .gitignore patterns."""
    for pattern in gitignore_patterns:
        if Path(path).match(pattern):
            return True
    return False

@app.command()
def dump_repo(
    folders: list[str] = typer.Argument(None, help="List of folders to include in the dump."),
    included_formats: list[str] = typer.Option([], "--include", "-i", help="List of file formats to include, such as 'py', 'md'."),
    excluded_formats: list[str] = typer.Option([], "--exclude", "-e", help="List of file formats to exclude, such as 'exe', 'tmp'."),
    file_name: str = typer.Option(None, "--file", "-f", help="The file to persist the results. Defaults to None, which means copy-paste buffer will be used.")
):
    """
    Dump the contents of a repository to a dictionary-like format.
    """
    if not folders:
        folders = [os.getcwd()]

    repo_contents = {}
    tokenizer = tiktoken.encoding_for_model("gpt-4")
    gitignore_patterns = []

    for folder in folders:
        gitignore_patterns.extend(read_gitignore_patterns(folder))
        for root, dirs, files in os.walk(folder):
            # Skip excluded directories (e.g., .git, cache)
            dirs[:] = [d for d in dirs if not is_excluded(os.path.join(root, d), gitignore_patterns) and d != '.git']
            for file in files:
                file_path = os.path.join(root, file)
                if is_excluded(file_path, gitignore_patterns):
                    continue
                file_extension = file.split('.')[-1]
                if included_formats and file_extension not in included_formats:
                    continue
                if excluded_formats and file_extension in excluded_formats:
                    continue
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        repo_contents[file_path] = content
                except UnicodeDecodeError:
                    print(f"Skipping file {file_path} due to encoding error.")
                except Exception as e:
                    print(f"An error occurred while reading file {file_path}: {e}")

    total_tokens = sum(len(tokenizer.encode(content)) for content in repo_contents.values())
    
    output_data = {
        "total_tokens": total_tokens,
        "repo_contents": repo_contents
    }

    if file_name:
        with open(file_name, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=4)
        typer.echo(f"File created: {file_name}, Total tokens: {total_tokens}")
    else:
        pyperclip.copy(json.dumps(output_data, indent=4))
        typer.echo(f"Copy-paste buffer updated, Total tokens: {total_tokens}")

if __name__ == "__main__":
    app()
