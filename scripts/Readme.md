# Generate Tests YAML Script

This Python script is designed to generate a YAML structure for running tests in a CI/CD pipeline. It reads .yaml files from a specified directory (assertoor-tests), applies optional filtering, and can slice the tests into groups for parallel execution.

## Features

- Recursive Directory Traversal: Automatically searches for .yaml test files within the assertoor-tests directory and its subdirectories.
- Inclusion and Exclusion Filters: Allows you to specify patterns to include or exclude specific test files.
- Grouping: Splits the tests into specified groups for parallel processing.

## Usage
To use the script, navigate to the root directory of your project and run the script using Python:

### Basic Usage

`python Scripts/generate_tests_yaml.py`

This will generate a YAML structure with all .yaml files found in the assertoor-tests directory and its subdirectories, excluding all.yaml.

### Filtering Tests
#### Include Specific Tests

To include only certain tests based on their filenames, use the --include option:

`python Scripts/generate_tests_yaml.py --include "validator" "proposal"`

This will include all files with validator or proposal in their filenames.

#### Exclude Specific Tests

To exclude certain tests based on their filenames, use the --exclude option:

`python Scripts/generate_tests_yaml.py --exclude "verkle" "blob"`

This will exclude all files with verkle or blob in their filenames.

### Slicing Tests for Parallel Execution

To divide the list of tests into groups for parallel execution, use the --groups option:

`python Scripts/generate_tests_yaml.py --groups 3`

This will split the tests into 3 groups.

### Raw Output Usage
To output the raw URLs without YAML formatting, use the --raw option:

`python Scripts/generate_tests_yaml.py --raw`

This will output the URLs as plain text, one per line:

```
https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/pectra-dev/test1.yaml
https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/verkle-dev/testA.yaml
...
```

## Example Output
The script will output the YAML structure in the format required for your CI/CD configuration:

```
tests:
    - https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/pectra-dev/test1.yaml
    - https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/verkle-dev/testA.yaml
    ...
```

If you use the --groups option, it will output separate YAML structures for each group.
