[![View the code](https://img.shields.io/badge/GitHub-View_the_Code-blue?logo=GitHub)](https://github.com/khuyentran1401/Data-science/blob/master/data_science_tools/schema.ipynb)

## Introduction to Schema: A Python Libary to Validate your Data

![](https://miro.medium.com/max/700/0*HSqvCAEj62jir0Lq)

Photo by [Nonsap Visuals](https://unsplash.com/@nonsapvisuals?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com/?utm_source=medium&utm_medium=referral)

### Motivation

In the last two sections, we learned how to validate a pandas DataFrame. However, sometimes you might want to validate Python data structures instead of a pandas DataFrame. That is when schema comes in handy. 

[**schema**](https://github.com/keleshev/schema) is a library for validating Python data structures.

Install schema with

```bash
pip install schema
```

### Validate Data Types

Imagine this is data that presents the information about your friends.


```python
[
    {'name': 'Norma Fisher',  'city': 'South Richard',  'closeness (1-5)': 4,  'extrovert': True,  'favorite_temperature': -45.74}, 
    {'name': 'Colleen Taylor',  'city': 'North Laurenshire',  'closeness (1-5)': 4,  'extrovert': False,  'favorite_temperature': 93.9}, 
    {'name': 'Melinda Kennedy',  'city': 'South Cherylside',  'closeness (1-5)': 1,  'extrovert': True,  'favorite_temperature': 66.33}
]
```

We can use schema to validate data types:

```python
from schema import Schema

schema = Schema([{'name': str,
                 'city': str, 
                 'closeness (1-5)': int,
                 'extrovert': bool,
                 'favorite_temperature': float}])
                 
schema.validate(data)
```

Since schema returns the output without throwing any error, we know that our data is valid.

Let’s see what happens if the data types are not like what we expect
```python
schema = Schema([{'name': int,
                 'city': str, 
                 'closeness (1-5)': int,
                 'extrovert': bool,
                 'favorite_temperature': float}])

schema.validate(data)
```
```bash
SchemaError: Or({'name': <class 'int'>, 'city': <class 'str'>, 'closeness (1-5)': <class 'int'>, 'extrovert': <class 'bool'>, 'favorite_temperature': <class 'float'>}) did not validate {'name': 'Norma Fisher', 'city': 'South Richard', 'closeness (1-5)': 3, 'extrovert': True, 'favorite_temperature': -45.74}
Key 'name' error:
'Norma Fisher' should be instance of 'int'
```

From the error, we know exactly which column and value of the data are different from what we expect. Thus, we can go back to the data to fix or delete that value.

If all you care about is whether the data is valid or not, use

```python
schema.is_valid(data)
```

This will return `True` if the data is as expected or `False` otherwise.

### Validate datatype of some columns while ignoring the rest

But what if we don’t care about the data types of all of the columns but just care about the value of some columns? We can specify that with `str: object`
```python
schema = Schema([{'name': str,
                 'city': str, 
                 'favorite_temperature': float,
                  str: object
                 }])
                
schema.is_valid(data)
```

```bash
Output: True
```

As you can see, we try to validate the data types of ‘name’, ‘city’, and ‘favorite\_temperature’, while ignoring the data types of the rest of the features in our data.

The data is valid because the data types of the 3 features specified are correct.

### Validate with Function

What if we want to determine whether the data within a column satisfies a specific condition that is not relevant to data types such as the range of the values in a column?

Schema allows you to use a function to specify the condition for your data.

If we want to check whether the values in the ‘closeness’ column is between 1 and 5, we can use `lambda` like below

```python
schema = Schema([{'name': str,
                 'city': str, 
                 'favorite_temperature': float,
                  'closeness (1-5)': lambda n : 1 <= n <= 5,
                  str: object
                 }])

schema.is_valid(data)
```

```bash
Output: True
```

As you can see, we specify `n,`the value in each row of the column ‘closeness’, to between 1 and 5 with `lambda n: 1 <= n <=5.` Neat!

### Validate Several Schemas

#### _And_

What if you want to make sure your ‘closeness’ column to be between 1 and 5 **and** the data type to be an integer?

That is when `And` comes in handy

```python
schema = Schema([{'name': str,
                 'city': str, 
                 'favorite_temperature': float,
                  'closeness (1-5)': And(lambda n : 1 <= n <= 5, float),
                  str: object
                 }])

schema.is_valid(data)
```

```bash
Output: False
```

While all the values are within 1 and 5, the data type is not a float. Because one of the conditions is not satisfied, the data is not valid.

#### _Or_

If we want the data of column to be valid if either of the conditions is satisfied, we can use `Or`

For example, if we want the city’s name to contain either 1 or 2 words, we can use
```python
schema = Schema([{'name': str,
                 'city': Or(lambda n: len(n.split())==2, lambda n: len(n.split()) ==1), 
                 'favorite_temperature': float,
                  'closeness (1-5)': int,
                  str: object
                 }])

schema.is_valid(data)
```

#### _Combination of And and Or_

What if we want the data type of ‘city’ to be a string but the length can be either 1 or 2? Luckily, this could be handled easily by combining `And` and `Or`.

```python
schema = Schema([{'name': str,
                 'city': And(str, Or(lambda n: len(n.split())==2, lambda n: len(n.split()) ==1)), 
                 'favorite_temperature': float,
                  'closeness (1-5)': int,
                  str: object
                 }])

schema.is_valid(data)
```

```bash
Output: True
```

### Optional

What if we **don’t have** the detailed information about **some** of your friends?

```python
[
    {'name': 'Norma Fisher',  'city': 'South Richard',  'closeness (1-5)': 4,  'detailed_info': {'favorite_color': 'Pink',   'phone number': '7593824219489'}}, 
    {'name': 'Emily Blair',  'city': 'Suttonview',  'closeness (1-5)': 4,  'detailed_info': {'favorite_color': 'Chartreuse',   'phone number': '9387784080160'}}, 
    {'name': 'Samantha Cook', 'city': 'Janeton', 'closeness (1-5)': 3}
]
```

Since the ‘detailed\_info’ of Samantha Cook is not available with all of your friends, we want to make this column optional. Schema allows us to set that condition with `Optional`

```bash
Output: True
```

### Forbidden

Sometimes, we might also want to make sure a certain kind of data is not in our data, such as private information. We can specify which column is forbidden with `Forbidden`

```python
from schema import Forbidden

schema = Schema([{'name': str,
                 'city':str,  
                  'closeness (1-5)': int,
                  Forbidden('detailed_info'): dict
                 }])
schema.validate(data)
```

```bash
Forbidden key encountered: 'detailed_info' in {'name': 'Norma Fisher', 'city': 'South Richard', 'closeness (1-5)': 4, 'detailed_info': {'favorite_color': 'Pink', 'phone number': '7593824219489'}}
```

Now we are aware of the existence of the forbidden column every time schema throws an error!

### Nested dictionary

So far, schema has enabled us to perform many sophisticated validations in several lines of code. But in the real-life, we might deal with a more sophisticated data structure than the example above.

Can we use it for data with a more complicated structure? Such as a dictionary within a dictionary? Yes we can.

Imagine our data looks like below:


```python
[
    {'name': 'Norma Fisher',  'city': 'South Richard',  'closeness (1-5)': 4,  'detailed_info': {'favorite_color': 'Pink',   'phone number': '7593824219489'}}, 
    {'name': 'Emily Blair',  'city': 'Suttonview',  'closeness (1-5)': 4,  'detailed_info': {'favorite_color': 'Chartreuse',   'phone number': '9387784080160'}}
]
```

We can validate with a nested dictionary

```python
schema = Schema([{'name': str,
                 'city':str,  
                  'closeness (1-5)': int,
                  'detailed_info': {'favorite_color': str, 'phone number': str}
                 }])
                 
schema.is_valid(data)
```

The syntax is straight forward! We just need to write another dictionary within the dictionary and specify the data type for each key.

### Convert Data Type

Not only can schema be used to validate data but also can be used to convert the data type if it happens not to be like what we expected!

For example, we can convert string ‘123’ to integer 123 with `Use(int)`

```python
Schema(Use(int)).validate('123')
```

```bash
123
```