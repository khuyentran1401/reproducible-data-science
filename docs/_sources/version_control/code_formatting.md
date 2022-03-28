[![View the code](https://img.shields.io/badge/GitHub-View_the_Code-blue?logo=GitHub)](https://github.com/khuyentran1401/Data-science/tree/master/productive_tools/precommit_examples)

## 4 pre-commit Plugins to Automate Code Reviewing and Formatting in Python

### Motivation

When committing your Python code to Git, you need to make sure your code:

-   looks nice
-   is organized
-   conforms to the PEP 8 style guide
-   includes docstrings

However, it can be overwhelming to check all of these criteria before committing your code. Wouldn’t it be nice if you can **automatically** check and format your code every time you commit new code like below?

![](https://miro.medium.com/max/700/1*b1KAkP6CXPx669MAV3CoQg.png)

That is when pre-commit comes in handy. In this section, you will learn what pre-commit is and which plugins you can add to a pre-commit pipeline.

### What is pre-commit?

pre-commit is a framework that allows you to identify simple issues in your code before committing it.

You can add different plugins to your pre-commit pipeline. Once your files are committed, they will be checked by these plugins. Unless all checks pass, no code will be committed.

![](https://miro.medium.com/max/700/1*VoFV8eM4iTCjZt7akM243Q.png)

To install pre-commit, type:

```bash
pip install pre-commit
```

Cool! Now let’s add some useful plugins to our pre-commit pipeline.

### black

[black](https://black.readthedocs.io/en/stable/) is a code formatter in Python.

To install black, type:

```bash
pip install black
```

Now to see what black can do, we’ll write a very long function like below. Since there are more than 79 characters in the first line of code, this violates PEP 8.

Let’s try to format the code using black:

```bash
$ black long_function.py
```

And the code is automatically formatted like below!

```python
def very_long_function(
    long_variable_name,
    long_variable_name2,
    long_variable_name3,
    long_variable_name4,
    long_variable_name5,
):
    pass
```

To add black to a pre-commit pipeline, create a file named `.pre-commit-config.yaml` and insert the following code to the file:
```yaml
repos:
-   repo: https://github.com/ambv/black
    rev: 20.8b1
    hooks:
    - id: black
```

### flake8

[flake8](https://flake8.pycqa.org/en/latest/) is a python tool that checks the style and quality of your Python code. It checks for various issues not covered by black.

To install flake8, type:

```bash
pip install flake8
```

To see what flake8 does, let’s write code that violates some guidelines in PEP 8.

```python
def very_long_function_name(var1, var2, var3,
var4, var5):
    print(var1, var2, var3, var4, var5)

very_long_function_name(1, 2, 3, 4, 5)
```

Next, check the code using flake8:

```bash
$ flake8 flake_example.py
```
```bash
flake8_example.py:2:1: E128 continuation line under-indented for visual indent
flake8_example.py:5:1: E305 expected 2 blank lines after class or function definition, found 1
flake8_example.py:5:39: W292 no newline at end of file
```
Aha! flake8 detects 3 PEP 8 formatting errors. We can use these errors as the guidelines to fix the code.

```python
def very_long_function_name(var1, var2, var3, var4, var5):
    print(var1, var2, var3, var4, var5)


very_long_function_name(1, 2, 3, 4, 5)
```

The code looks much better now!

To add flake8 to the pre-commit pipeline, insert the following code to the `.pre-commit-config.yaml` file:
```yaml
-   repo: https://gitlab.com/pycqa/flake8
    rev: 3.8.4
    hooks:
    - id: flake8
```

### isort

[isort](https://github.com/PyCQA/isort) is a Python library that automatically sorts imported libraries alphabetically and separates them into sections and types.

To install isort, type:

```bash
pip install isort
```

Let’s try to use isort to sort messy imports like below:

```python
import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt
from flake8_example import very_long_function_name
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression, OrderedLogisticRegression, \
    LinearRegression, LogisticRegressionCV, LinearRegressionCV 
```

```bash
$ isort isort_example.py
```

Output:
```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from flake8_example import very_long_function_name
from sklearn.linear_model import (
    LinearRegression,
    LinearRegressionCV,
    LogisticRegression,
    LogisticRegressionCV,
    OrderedLogisticRegression,
)
from sklearn.model_selection import train_test_split
```

Cool! The imports are much more organized now.

To add isort to the pre-commit pipeline, add the following code to the `.pre-commit-config.yaml` file:
```yaml

-   repo: https://github.com/timothycrosley/isort
    rev: 5.7.0
    hooks:
    -   id: isort
```

### interrogate

[interrogate](https://interrogate.readthedocs.io/en/latest/index.html?highlight=pre-commit) checks your codebase for missing docstrings.

To install interrogate, type:

```bash
pip install interrogate
```

Sometimes, we might forget to write docstrings for classes and functions like below:
```python
class MathOperation:
    def __init__(self, num) -> None:
        self.num = num 

    def plus_two(self):
        return self.num + 2

    def multiply_three(self):
        return self.num * 3
```

Instead of manually looking at all our functions and classes for missing docstrings, we can run interrogate instead:

```bash
$ interrogate -vv interrogate_example.py
```

Output:

![](https://miro.medium.com/max/700/1*8CeDRAfu9SuVOWcvpGjw8A.png)

Cool! From the terminal output, we know which files, classes, and functions don’t have docstrings. Since we know the locations of missing docstrings, adding them is easy.

```python
"""Example for interrogate"""

class MathOperation:
    """Perform math operation"""
    def __init__(self, num) -> None:
        self.num = num 

    def plus_two(self):
        """Add 2"""
        return self.num + 2

    def multiply_three(self):
        """Multiply by 3"""
        return self.num * 3
```

```bash
$ interrogate -vv interrogate_example.py
```

![](https://miro.medium.com/max/700/1*z7ixNpScwuuTzOg4GLWODw.png)

The docstring for the `__init__` method is missing, but it is not necessary. We can tell interrogate to ignore the `__init__` method by adding `-i` to the argument:

```bash
$ interrogate -vv -i interrogate_example.py
```

![](https://miro.medium.com/max/700/1*jy7bW4OCOSZHBjvglxdCCg.png)

Cool! To add interrogate to the pre-commit pipeline, insert the following code to the `.pre-commit-config.yaml` file:
```yaml
- repo: https://github.com/econchick/interrogate
    rev: 1.4.0  
    hooks:
      - id: interrogate
        args: [--vv, -i, --fail-under=80]
```

### Final Step — Add pre-commit to Git Hooks

The final code in your `.pre-commit-config.yaml` file should look like below:
```yaml
repos:
-   repo: https://github.com/ambv/black
    rev: 20.8b1
    hooks:
    - id: black
-   repo: https://gitlab.com/pycqa/flake8
    rev: 3.8.4
    hooks:
    - id: flake8
-   repo: https://github.com/timothycrosley/isort
    rev: 5.7.0
    hooks:
    -   id: isort
-   repo: https://github.com/econchick/interrogate
    rev: 1.4.0  
    hooks:
    - id: interrogate
      args: [-vv, -i, --fail-under=80]
```
To add pre-commit to git hooks, type:

```bash
$ pre-commit install
```

Output:

```bash
pre-commit installed at .git/hooks/pre-commit
```

### Commit

Now we’re ready to commit the new code!

```bash
$ git commit -m 'add pre-commit examples'
```

And you should see something like below:

![](https://miro.medium.com/max/700/1*b1KAkP6CXPx669MAV3CoQg.png)

### Skip Verifying

To prevent pre-commit from checking a certain commit, add `--no-verify` to `git commit` :

```bash
$ git commit -m 'add pre-commit examples' --no-verify
```

### Customization

#### Black

To choose which files to include and exclude when running black, create a file named `pyproject.toml` and add the following code to the `pyproject.toml` file:

```bash
[tool.black]
line-length = 79
include = '\.pyi?$'
exclude = '''
/(
	\.git
| \.hg
| \.mypy_cache
| \.tox
| \.venv
| _build
| buck-out
| build   
)/ 
'''
```

#### flake8

To choose which errors to ignore or to edit other configurations, create a file named `.flake8` and add the following code to the `.flake8` file:
```bash
[flake8]
ignore = E203, E266, E501, W503, F403, F401
max-line-length = 79
max-complexity = 18
select = B,C,E,F,W,T4,B9
```

#### interrogate

To edit interrogate’s default configurations, insert the following code to the`pyproject.toml` file:

```bash
[tool.interrogate]
ignore-init-method = true
ignore-init-module = false
ignore-magic = false
ignore-semiprivate = false
ignore-private = false
ignore-property-decorators = false
ignore-module = true
ignore-nested-functions = false
ignore-nested-classes = true
ignore-setters = false
fail-under = 95
exclude = ["setup.py", "docs", "build"]
ignore-regex = ["^get$", "^mock_.*", ".*BaseClass.*"]
verbose = 0
quiet = false
whitelist-regex = []
color = true
generate-badge = "."
badge-format = "svg"
```