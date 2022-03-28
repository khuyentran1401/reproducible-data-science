# Test Code

It is fun to apply different python code to process your data in your notebook, but in order to make your code reproducible, you need to put them into functions and classes. When you put your code in the script, the code may break because of some functions. Even if you code doesn’t break, how do you know if your function will work as you expected?

For example, we create a function to extract the sentiment of a text with [TextBlob](https://textblob.readthedocs.io/en/dev/), a Python library for processing textual data. We want to make sure it works as we expect: the function returns a value that is greater than 0 if the test is positive and returns a value that is less than 0 if the text is negative.

```python
from textblob import TextBlob

def extract_sentiment(text: str):
        '''Extract sentiment using textblob. 
        Polarity is within range [-1, 1]'''

        text = TextBlob(text)

        return text.sentiment.polarity
```

To find out whether the function will return the right value for every time, the best way is to apply the functions to different examples to see if it produces the results we want. That is when testing becomes important.

In general, you should use testing for your data science projects because it allows you to:

-   Make sure the code works as expected
-   Detect edge cases
-   Feel confident to swap your existing code with improved code without being afraid of breaking the entire pipeline
-   Your teammates can understand your functions by looking at your tests.

In this chapter, you will learn how to test your code with Pytest.