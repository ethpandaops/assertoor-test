import os
from pathlib import Path
import argparse
import math
import json

script_dir = Path(__file__).resolve().parent
repo_dir = script_dir.parents[1]
tests_dir = repo_dir / "assertoor-tests"

def get_yaml_files(tests_dir, branch="master", include=None, exclude=None):
    yaml_files = []
    for root, _, files in os.walk(tests_dir):
        for file in files:
            if file.endswith(".yaml"):
                full_path = Path(root) / file
                
                if file == "all.yaml":
                    continue
                
                if include and not any(inc in str(full_path) for inc in include):
                    continue
                
                if exclude and any(exc in str(full_path) for exc in exclude):
                    continue
                
                raw_url = f"https://raw.githubusercontent.com/ethpandaops/assertoor-test/{branch}/{full_path.relative_to(repo_dir)}"
                yaml_files.append(raw_url)
    
    return yaml_files

def construct_yaml_structure(yaml_files):
    yaml_structure = "assertoor_params:\n"
    yaml_structure += "  tests:\n"
    for url in yaml_files:
        yaml_structure += f"    - {{ file: \"{url}\" }}\n"
    return yaml_structure

def slice_tests(yaml_files, groups):
    sliced_groups = []
    group_size = math.ceil(len(yaml_files) / groups)
    for i in range(0, len(yaml_files), group_size):
        sliced_groups.append(yaml_files[i:i + group_size])
    return sliced_groups

def main():
    parser = argparse.ArgumentParser(description="Generate test URLs with optional filtering, slicing, and formatting.")
    parser.add_argument("--branch", type=str, default="master", help="The branch name to use for constructing the raw URLs.")
    parser.add_argument("--include", type=str, nargs='*', help="List of texts to include in file names (only include matching files).")
    parser.add_argument("--exclude", type=str, nargs='*', help="List of texts to exclude from file names (exclude matching files).")
    parser.add_argument("--groups", type=int, help="Number of groups to slice the tests into.", default=1)
    parser.add_argument("--raw", action="store_true", help="Output raw URLs without YAML formatting.")
    parser.add_argument("--json", action="store_true", help="Output URLs in JSON format.")
    
    args = parser.parse_args()

    yaml_files = get_yaml_files(tests_dir, branch=args.branch, include=args.include, exclude=args.exclude)
    sliced_yaml_files = slice_tests(yaml_files, args.groups)

    if args.json:
        json_output = {str(idx + 1): group for idx, group in enumerate(sliced_yaml_files)}
        print(json.dumps(json_output, indent=2))
    else:
        for idx, group in enumerate(sliced_yaml_files, start=1):
            if args.raw:
                print("\n".join(group) + "\n")
            else:
                print(construct_yaml_structure(group))

if __name__ == "__main__":
    main()
