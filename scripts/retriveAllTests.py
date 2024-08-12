import os
from pathlib import Path
import argparse
import math

repo_dir = Path(__file__).resolve().parents[1]
tests_dir = repo_dir / "assertoor-tests"

def get_yaml_files(tests_dir, include=None, exclude=None):
    yaml_files = []
    for root, _, files in os.walk(tests_dir):
        for file in files:
            if file.endswith(".yaml"):
                if file == "all.yaml":
                    continue
                if include and not any(inc in file for inc in include):
                    continue
                if exclude and any(exc in file for exc in exclude):
                    continue
                full_path = Path(root) / file
                raw_url = f"https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/{full_path.relative_to(repo_dir)}"
                yaml_files.append(raw_url)
    return yaml_files

def construct_yaml_structure(yaml_files):
    yaml_structure = "tests:\n"
    for url in yaml_files:
        yaml_structure += f"    - {url}\n"
    return yaml_structure

def slice_tests(yaml_files, groups):
    sliced_groups = []
    group_size = math.ceil(len(yaml_files) / groups)
    for i in range(0, len(yaml_files), group_size):
        sliced_groups.append(yaml_files[i:i + group_size])
    return sliced_groups

def main():
    parser = argparse.ArgumentParser(description="Generate test URLs with optional filtering, slicing, and formatting.")
    parser.add_argument("--include", type=str, nargs='*', help="List of texts to include in file names (only include matching files).")
    parser.add_argument("--exclude", type=str, nargs='*', help="List of texts to exclude from file names (exclude matching files).")
    parser.add_argument("--groups", type=int, help="Number of groups to slice the tests into.", default=1)
    parser.add_argument("--raw", action="store_true", help="Output raw URLs without YAML formatting.")
    
    args = parser.parse_args()

    yaml_files = get_yaml_files(tests_dir, include=args.include, exclude=args.exclude)
    sliced_yaml_files = slice_tests(yaml_files, args.groups)

    for idx, group in enumerate(sliced_yaml_files, start=1):
        if args.raw:
            print(f"\n".join(group) + "\n")
        else:
            print(f"{construct_yaml_structure(group)}\n")

if __name__ == "__main__":
    main()
