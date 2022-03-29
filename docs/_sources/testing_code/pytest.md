[![View the code](https://img.shields.io/badge/GitHub-View_the_Code-blue?logo=GitHub)](https://github.com/khuyentran1401/Data-science/tree/master/data_science_tools/pytest) 

## Pytest for Data Scientists

![](https://miro.medium.com/max/700/1*NdxIFtI2AeW3WkTaFePRjA.jpeg)

### What is Pytest?

[Pytest](https://docs.pytest.org/en/stable/) is the framework that makes it easy to write small tests in Python. I like pytest because it helps me to write tests with minimal code. If you were not familiar with testing, pytest is a great tool to get started.

To install pytest, run

```bash
pip install -U pytest
```

To test the function shown above, we can simply create a function that starts with `test_` and followed with the name of the function we want to test, which is `extract_sentiment`.

```python
#sentiment.py
def extract_sentiment(text: str):
        '''Extract sentiment using textblob. 
        Polarity is within range [-1, 1]'''

        text = TextBlob(text)

        return text.sentiment.polarity

def test_extract_sentiment():

    text = "I think today will be a great day"

    sentiment = extract_sentiment(text)

    assert sentiment > 0
```

Within the test function, we apply the function `extract_sentiment` to an example text: ‘I think today will be a great day’. We use `assert sentiment > 0` to make sure that the sentiment is positive.

That’s it! Now we are ready to run the test.

If the name of our script is `sentiment.py`, we can run

```bash
pytest sentiment.py
```

Pytest will loop through our script and run the functions that start with `test`. The output of the test above will look like this:

```bash
========================================== 1 passed in 0.68s ===========================================
```

Pretty cool! We don’t need to specify which function to test. As long as the function’s name starts with `test,` pytest will detect and execute that function! We don’t even need to import pytest in order to run pytest

What is the output pytest produces if the test fails?

```python
#sentiment.py

def test_extract_sentiment():

    text = "I think today will be a great day"

    sentiment = extract_sentiment(text)

    assert sentiment < 0
```
```bash
$ pytest sentiment.py
_______________________________________ test_extract_sentiment ________________________________________

def test_extract_sentiment():
    
        text = "I think today will be a great day"
    
        sentiment = extract_sentiment(text)
    
>       assert sentiment < 0
E       assert 0.8 < 0
========================================== 1 failed in 0.84s ===========================================
```

From the output, we can see that the test failed because the sentiment of the function is 0.8, and it is not less than 0! We are not only able to know whether our function works as expected but also know WHY it doesn’t work. From this insight, we know where to fix our function to work as we want.

### Multiple Tests for the Same Function

We might want to test our function with other examples. What will the name of the new test function be?

The second function’s name can be something like `test_extract_sentiment_2` or `test_extract_sentiment_negative` if we want to test our function on a text with negative sentiment. Any function name would work as long as it starts with `test`:

```python
#sentiment.py

def test_extract_sentiment_positive():

    text = "I think today will be a great day"

    sentiment = extract_sentiment(text)

    assert sentiment > 0

def test_extract_sentiment_negative():

    text = "I do not think this will turn out well"

    sentiment = extract_sentiment(text)

    assert sentiment < 0
```

```bash
$ pytest sentiment.py
___________________________________ test_extract_sentiment_negative ____________________________________

def test_extract_sentiment_negative():
    
        text = "I do not think this will turn out well"
    
        sentiment = extract_sentiment(text)
    
>       assert sentiment < 0
E       assert 0.0 < 0
===================================== 1 failed, 1 passed in 0.80s ======================================
```

From the output, we know that one test passed and one failed and why the test failed. We expect the sentence "I do not think this will turn out well" to be negative, but it turns out to be 0.

This helps us to understand that the function might not be accurate 100% of the time; thus, we should be cautious when using this function to extract the sentiment of a text.

### Parametrization: Combining Tests

The 2 test functions above are used to test the same function. Is there any way we can combine 2 examples into one test function? That is when parameterization comes in handy.

#### Parametrize with a List of Samples

With `pytest.mark.parametrize()` , we can execute a test with different examples by providing a list of examples in the argument.

```python
# sentiment.py

from textblob import TextBlob
import pytest

def extract_sentiment(text: str):
        '''Extract sentiment using textblob. 
        Polarity is within range [-1, 1]'''

        text = TextBlob(text)

        return text.sentiment.polarity

testdata = ["I think today will be a great day","I do not think this will turn out well"]

@pytest.mark.parametrize('sample', testdata)
def test_extract_sentiment(sample):

    sentiment = extract_sentiment(sample)

    assert sentiment > 0
```

In the code above, we assign the variable `sample` to a list of samples, then add that variable to the argument of our test function. Now each example will be tested once at a time.

```bash
_____ test_extract_sentiment[I do not think this will turn out well] _____

sample = 'I do not think this will turn out well'
@pytest.mark.parametrize('sample', testdata)
    def test_extract_sentiment(sample):
    
        sentiment = extract_sentiment(sample)
    
>       assert sentiment > 0
E       assert 0.0 > 0
====================== 1 failed, 1 passed in 0.80s ===================
```

Using `parametrize()`, we are able to test 2 different examples in once function!

#### Parametrize with a List of Examples and Expected Outputs

What if we expect **different examples** to have **different outputs**? Pytest also allows us to add examples and expected outputs to the argument of our test function!

For example, the function below checks if the text contains a particular word.
```python
def text_contain_word(word: str, text: str):
    '''Find whether the text contains a particular word'''
    
    return word in text
```

It will return `True` if the text contains the word.

If the word is ‘duck’ and the text is ‘There is a duck in this text”, we expect the sentence to return `True.`

If the word is ‘duck’ and the text is ‘There is nothing here”, we expect the sentence to return `False.`

We will use `parametrize()` but with a list of tuples instead.

```python
# process.py
import pytest
def text_contain_word(word: str, text: str):
    '''Find whether the text contains a particular word'''
    
    return word in text

testdata = [
    ('There is a duck in this text',True),
    ('There is nothing here', False)
    ]

@pytest.mark.parametrize('sample, expected_output', testdata)
def test_text_contain_word(sample, expected_output):

    word = 'duck'

    assert text_contain_word(word, sample) == expected_output
```

The structure of the parameters for our function is`parametrize(‘sample, expected_out’, testdata)` with `testdata=[(<sample1>, <output1>), (<sample2>, <output2>)`

```bash
$ pytest process.py

========================================== 2 passed in 0.04s ===========================================
```

Awesome! Both of our tests passed!

### Test one Function at a time

When the number of test functions in your script gets bigger, you may want to test one function instead of multiple functions at once. That could be easily done with `pytest file.py::function_name`.
```python
testdata = ["I think today will be a great day","I do not think this will turn out well"]

@pytest.mark.parametrize('sample', testdata)
def test_extract_sentiment(sample):

    sentiment = extract_sentiment(sample)

    assert sentiment > 0


testdata = [
    ('There is a duck in this text',True),
    ('There is nothing here', False)
    ]

@pytest.mark.parametrize('sample, expected_output', testdata)
def test_text_contain_word(sample, expected_output):

    word = 'duck'

    assert text_contain_word(word, sample) == expected_output
```

For example, if you just want to run `test_text_contain_word`, run:

```bash
$ pytest process.py::test_text_contain_word
```

And pytest will just execute one test that we specify!

### Fixtures: Use the Same Data to Test Different Functions

What if we want to use the same data to test different functions? For example, we want to test whether the sentence ‘Today I found a duck and I am happy” contains the word ‘duck’ **and** its sentiment is positive. We want to apply 2 functions for the same data: ‘Today I found a duck and I am happy”. That is when `fixture` comes in handy.

`pytest` fixtures are a way of providing data to different test function:
```python
@pytest.fixture
def example_data():
    return 'Today I found a duck and I am happy'


def test_extract_sentiment(example_data):

    sentiment = extract_sentiment(example_data)

    assert sentiment > 0

def test_text_contain_word(example_data):

    word = 'duck'

    assert text_contain_word(word, example_data) == True
```

In the example above, we create an example data with the decorator `@pytest.fixture` above the function `example_data.` This will turn `example_data` into a variable with value "Today I found a duck and I am happy".

Now, we can use `example_data` as the parameters for any tests!

### Structure your Projects

Last but not least, when our code grows bigger, we might want to put data science functions and test functions in 2 different folders. This will make it easier for us to find the location for each function.

Name our test function with either `test_<name>.py` or `<name>_test.py` . Pytest will search for the file whose name ends or starts with ‘test’ and executes the functions whose name starts with ‘test’ within that file. 

There are different ways to organize your files. You can either organize our data science file and test file in the same directory or in 2 different directories, one for source code and one for tests

Method 1:

```bash
test_structure_example/
├── process.py
└── test_process.py```
```

Method 2:

```bash
test_structure_example/
├── src
│   └── process.py
└── tests
    └── test_process.py
```

Since you will most likely have multiple files for your data science functions and multiple files for your test functions, you might want to put them in separate directories like method 2.

This is how 2 files will look like

```python
from textblob import TextBlob

def extract_sentiment(text: str):
        '''Extract sentiment using textblob. 
        Polarity is within range [-1, 1]'''

        text = TextBlob(text)

        return text.sentiment.polarity
```
```python
import sys
import os.path
sys.path.append(
    os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir)))
from src.process import extract_sentiment
import pytest


def test_extract_sentiment():

    text = 'Today I found a duck and I am happy'

    sentiment = extract_sentiment(text)

    assert sentiment > 0
```
 Simply add `sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir)))` to import functions from the parent directory.

Under the root directory (`test_structure_example/`), run `pytest tests/test_process.py` or run `pytest test_process.py`.

```bash
=========================== 1 passed in 0.69s ============================
```