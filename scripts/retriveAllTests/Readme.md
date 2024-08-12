# Generate Tests YAML Script

This Python script is designed to generate a YAML structure for running tests in a CI/CD pipeline. It reads .yaml files from a specified directory (assertoor-tests), applies optional filtering, and can slice the tests into groups for parallel execution.

## Features

- Recursive Directory Traversal: Automatically searches for .yaml test files within the assertoor-tests directory and its subdirectories.
- Inclusion and Exclusion Filters: Allows you to specify patterns to include or exclude specific test files.
- Grouping: Splits the tests into specified groups for parallel processing.

## Usage
To use the script, navigate to the root directory of your project and run the script using Python:

### Basic Usage

`python retriveAllTests.py`

This will generate a YAML structure with all .yaml files found in the assertoor-tests directory and its subdirectories, excluding all.yaml.

### Branch Selection
To specify a branch other than the default (master), use the --branch option:

`python SretriveAllTests.py --branch "pectra"`

This command will use the pectra branch instead of master to retrieve the test files.

*WARNING*
This is only a branch replacement feature in path - make sure to checkout repository on proper branch before applying this parameter.

### Filtering Tests
#### Include Specific Tests

To include only certain tests based on their filenames, use the --include option:

`python retriveAllTests.py --include "validator" "proposal"`

This will include all files with validator or proposal in their filenames.

#### Exclude Specific Tests

To exclude certain tests based on their filenames, use the --exclude option:

`python retriveAllTests.py --exclude "verkle" "blob"`

This will exclude all files with verkle or blob in their filenames.

### Slicing Tests for Parallel Execution

To divide the list of tests into groups for parallel execution, use the --groups option:

`python retriveAllTests.py --groups 3`

This will split the tests into 3 groups.

### Raw Output Usage

To output the raw URLs without YAML formatting, use the --raw option:

`python retriveAllTests.py --raw`

This will output the URLs as plain text, one per line:

```
https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/pectra-dev/test1.yaml
https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/verkle-dev/testA.yaml
...
```

### Json Output Usage

To output the test URLs in JSON format, use the --json option:

`python retriveAllTests.py --json`

This will output the URLs in a JSON format, like so:

```
{
  "1": [
    "https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/pectra-dev/test1.yaml",
    "https://raw.githubusercontent.com/ethpandaops/assertoor-test/master/assertoor-tests/verkle-dev/testA.yaml",
    ...
  ]
}
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
