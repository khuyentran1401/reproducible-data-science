[![View the code](https://img.shields.io/badge/GitHub-View_the_Code-blue?logo=GitHub)](https://github.com/khuyentran1401/Data-science/tree/master/data_science_tools/advanced_pytest) 

## 4 Useful Tips for Pytest

![](https://miro.medium.com/max/700/0*Thjx7rZfjHz_aKPp)

### Motivation

[**Pytest**](https://docs.pytest.org/en/stable/) is the ideal framework that makes it easy to write small tests in Python. I covered the benefits of unit testing and how to get started with pytest in the last section.

In this section, I will show you how to:

-   Filter warnings
-   Print the output of the function being tested
-   Benchmark your code
-   Repeat a single test for a specific number of times

### Filter warnings

It is common to see deprecation warnings when running pytest. The warnings might not be necessary and appear annoying when we just want to debug our code. Luckily, we can filter pytest warnings.

I will borrow the examples from [my previous pytest section](pytest.md). In this example, I want to test whether TextBlob accurately predicts the sentiment of a text. If you don’t know about TextBlob, you can learn more about the tool [here](https://towardsdatascience.com/supercharge-your-python-string-with-textblob-2d9c08a8da05).

```python
from textblob import TextBlob

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

When we test this script using:

```bash
$ pytest test_example.py
```

... we will see warnings.

In order to filter the warnings, create a file called `pytest.ini` in the same directory that we run our script:

```bash
.
├── pytest.ini
└── test_example.py
```

Then insert the content below inside the `pytest.ini`:

```bash
[pytest]
addopts = -p no:warnings
```

That’s it! Now rerun our test. We will have a clean output without the warnings!

### Print the Output

Sometimes we might want to see the intermediate output before writing `assert` statement. Why not print the output to know the intermediate output?

This will also help us develop a function that produces the output we want.

For example, we can print `text.sentiment` to know what exactly `text.sentiment` does:
```python
from textblob import TextBlob

def extract_sentiment(text: str):
  '''Extract sentiment using textblob. 
  Polarity is within range [-1, 1]'''

  text = TextBlob(text)

  print(text.sentiment)

  return text.sentiment.polarity

def test_extract_sentiment():

    text = "I think today will be a great day"

    sentiment = extract_sentiment(text)

    assert sentiment > 0
```

When running `pytest test_example.py`, we will see no output. In order to see the output of the`print` function, we need to include `-s` at the end of our command:

```bash
$ pytest test_example.py -s
======================= 1 passed in 0.49s =======================
```

Awesome! Now we know we can use `text.sentiment.polarity` to get the [polarity of the sentiment.](https://towardsdatascience.com/supercharge-your-python-string-with-textblob-2d9c08a8da05#087d)

### Repeat One Test Multiple Times

Sometimes we might want to run one test 100 times to make sure the function always works as expected.

For example, we discovered the method to combine 2 Python lists

```python
l1 = [1,2,3]
l2 = [4,5,6]
l1.extend(l2)
l1
```
```bash
[1,2,3,4,5,6]
```
From the output, it seems like the values in the list `l2` are inserted after the values in the list `l1`. But is the order always that way with every pair of lists?

To make sure the order of insertion is preserved when using the function`extend`, we can create two random lists then test it 100 times. If all tests pass, we are certain that the function will always work as we expected

To repeat a single test, install `pytest-repeat`:

```bash
$ pip install pytest-repeat
```

Now use `pytest.mark.repeat(100)` as the decorator of the test function we want to repeat

```python
import pytest 
import random 

def extend(l1,l2):
    l1.extend(l2)
    return l1
def test_extend():
    l1 = [1,2,3]
    l2 = [4,5,6]
    res = extend(l1, l2)
    assert res == [1,2,3,4,5,6]
    
@pytest.mark.repeat(100)
def test_extend_random():
  '''Generate random list and repeat the test 100 times'''
    l1 = []
    l2 = []
    for _ in range(0,3):
        n = random.randint(1,10)
        l1.append(n)
        n = random.randint(1,10)
        l2.append(n)

    res = extend(l1,l2)
    
    assert res[-(len(l2)):] == l2
```

```bash
$ pytest test_repeat.py 
======================= 101 passed in 0.09s =======================
```

Awesome. Now we are certain that the order of insertion will always be preserved when using `extend()` since 101 tests passed.

If you want to be more certain, increase the number to 1000 and see what you get. You can find more about `pytest-repeat` [here](https://pypi.org/project/pytest-repeat/).

### Benchmark your Code

We might not only want to assert the outputs are what we expected, but we also want to compare the speed of different functions.

A **benchmark** is a test that we can use to measure how fast our code is.

Luckily, there is a library called `pytest-benchmark` that allows us to benchmark our code while testing our function with pytest!

Install `pytest-benchmark` with:

```bash
pip install pytest-benchmark
```

I will borrow the examples from my article on [timing for efficient Python code](https://towardsdatascience.com/timing-the-performance-to-choose-the-right-python-object-for-your-data-science-project-670db6f11b8e) to show how we can use `pytest-benchmark.`

Here we test how long it takes to create a list using `concat` method:

```python
def concat(len_list=1000):
    l = []
    for i in range(len_list):
        l = l + [i]
    return l 
    
def test_concat(benchmark):

    res = benchmark(concat)
```

![](https://miro.medium.com/max/700/1*2ja75UdRPhJaLn5Kz3KM4Q.png)

The mean time of running `concat` is 792.1252 microseconds. We can see other measurements such as the min time and max time!

We can also insert parameters for the test function and repeat the tests 100 times to get a more accurate estimation of how fast the code is executed.

```python

def concat(len_list=1000):
    l = []
    for i in range(len_list):
        l = l + [i]
    return l 
    
def test_concat(benchmark):

    len_list = 1000 
    res = benchmark.pedantic(concat, kwargs={'len_list': len_list}, iterations=100)
    assert res == list(range(len_list))
```

![](https://miro.medium.com/max/700/1*0ysqfM67lg6cdIHrnGSfGg.png)

We get a different mean of 730 microseconds.

Now let’s use `pytest-benchmark` to compare multiple methods to create a list ranging from 0 to 999.
```python
def concat(len_list):
    l = []
    for i in range(len_list):
        l = l + [i]
    return l 

def append(len_list):
    l = []
    for i in range(len_list):
        l.append(i)
    return l 

def comprehension(len_list):
    l = [i for i in range(len_list)]
    return l 
    
def list_range(len_list):
    l = list(range(len_list))
    return l 

def test_concat(benchmark):

    len_list = 1000
    res = benchmark.pedantic(concat, kwargs={'len_list': len_list}, iterations=100)
    assert res == list(range(len_list))

def test_append(benchmark):

    len_list = 1000
    res = benchmark.pedantic(append, kwargs={'len_list': len_list}, iterations=100)
    assert res == list(range(len_list))

def test_comprehension(benchmark):

    len_list = 1000
    res = benchmark.pedantic(comprehension, kwargs={'len_list': len_list}, iterations=100)
    assert res == list(range(len_list))

def test_list_range(benchmark):
    len_list = 1000
    res = benchmark.pedantic(list_range, kwargs={'len_list': len_list}, iterations=100)
    assert res == list(range(len_list))
```

![](https://miro.medium.com/max/700/1*eNMmh8kC3l7DY8NcPpWhlw.png)

The output is nice and easy to read! 

We know that the `concat` method takes more time to execute than other methods, but how much longer?

We can visualize the results using `--benchmark-historgram`

```bash
pytest test_benchmark.py --benchmark-histogram
```

![](https://miro.medium.com/max/700/1*IjxjbiloXfuJSdE_bymF2w.png)

Wow! The `concat` method takes much longer to run compared to other methods.

You can learn more about `pytest-benchmark` [here](https://pypi.org/project/pytest-benchmark/).