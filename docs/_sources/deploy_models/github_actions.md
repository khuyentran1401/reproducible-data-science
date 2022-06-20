[![View the code](https://img.shields.io/badge/GitHub-View_the_Code-blue?logo=GitHub)](https://github.com/khuyentran1401/employee-future-prediction)

## GitHub Actions in MLOps: Automatically Check and Deploy Your ML Model

### Motivation

Imagine your company is creating an ML powered service. As a data scientist, you might try to continuously improve the existing ML model.

Once you find a better model, how do you make sure the service doesn’t break when you deploy the new model?

Wouldn’t it be nice if you can create a workflow that:

-   Automatically tests a pull request from a team member
-   Merges a pull request when all tests passed
-   Deploys the ML model to the existing service?

![](https://miro.medium.com/max/700/1*VZLOx6sCq9_Dj1-44mxKOQ.png)

In this section, you will learn how to create such a workflow with GitHub Actions.

### What is GitHub Actions?

[GitHub Actions](https://github.com/features/actions) allows you to automate your workflows, making it faster to build, test, and deploy your code.

In general, a workflow will look similar to the below:
```yaml
name: Workflow Name # Name of the workflow
on: push # Define which events can cause the workflow to run
jobs: # Define a list of jobs
  first_job: # ID of the job
    name: First Job # Name of the job
    runs-on: ubuntu-latest # Name of machine to run the job on
    steps:
      ...
  second_job:
    name: Second Job
    runs-on: ubuntu-latest
    steps: 
      ...
```
There are 3 important concepts to understand from the code above:

-   When an _event_ occurs (such as a push or a pull request), a _workflow_ consisting of one or more _jobs_ will be triggered
-   _Jobs_ are **independent** of each other. Each _job_ is a set of _steps_ that runs inside its own virtual machine runner or inside a container.
-   _Steps_ are **dependent** on each other and are executed in order.

![](https://miro.medium.com/max/511/1*sE4nHMwuBhN2bp4gLdUpvA.png)

Let’s dig deeper into these concepts in the next few sections.

### Find the Best Parameters

The first steps in an ML project include experimenting with different parameters and models in a non-master branch. In the section about version control, I mentioned how to [use MLFlow+ DagsHub to log your experiments](../version_control/dagshub.md).

![](https://miro.medium.com/max/700/1*AVtGMnz8_2K3dOtQAKCTdQ.png)

[_Link to the experiments shown above._](https://dagshub.com/khuyentran1401/employee-future-prediction/experiments/)

Once we found a combination of parameters and models that has a better performance than the existing model in production, we create a pull request to merge the new code with the master branch.

### Use GitHub Actions to Test Code, ML Model, and Application

To make sure that merging new code won’t cause any errors, we will create a workflow that:

-   automatically tests the pull requests
-   only allows the pull requests that pass all tests to merge with the master branch.

![](https://miro.medium.com/max/700/1*hYBqiJuqZ7qL0R6CZrRtgA.png)

We will write this workflow inside a YAML file under `.github/workflows` .

```bash
.github
└── workflows
    └── test_code.yaml
```

#### Specify Events

![](https://miro.medium.com/max/121/1*22Qe6bkxIED4J2F6f4O7-g.png)

In this workflow, we use `on` to specify that the workflow will only run :

-   If an event is a pull request.
-   If the paths of the committed files match certain patterns.

```yaml
name: Test code and app
on:
  pull_request:
    paths: # Run when one or more paths match a pattern listed below
      - config/**
      - training/**
      - application/**
      - .github/workflows/test_code.yaml
```

#### Specify Steps

Next, create a job called `test_code` , which consists of several steps executed in order.
```yaml
jobs:
  test_model:
    name: Test new model
    runs-on: ubuntu-latest
    steps:
      ...
```

The first few steps will set up the environment before running the code.
```yaml

steps:
  - name: Checkout # Check out a repo
    uses: actions/checkout@v2

  - name: Environment setup # Set up with a specific version of Python
    uses: actions/setup-python@v2
    with:
      python-version: 3.8
      cache: pip

  - name: Cache # Cache dependencies
    uses: actions/cache@v2
    with:
      path: ~/.cache/pip
      key: ${{ runner.os }}-pip-${{ hashFiles('**/dev-requirements.txt') }}
      restore-keys: ${{ runner.os }}-pip-
  
  - name: Install packages # Install dependencies
    run: pip install -r dev-requirements.txt
  
  - name: Pull data # Get data from remote storage
    run: |
      dvc remote modify origin --local auth basic
      dvc remote modify origin --local user khuyentran1401
      dvc remote modify origin --local password MyScretPassword
      dvc pull -r origin train_model
```

Explanations of the syntax in the code above:

-   `name` : A name for your step
-   `uses` selects an _action,_ which is an application that performs a complex but frequently repeated task. You can choose an action from thousands of actions on [GitHub Marketplace](https://github.com/marketplace?type=actions).
-   `with` inserts input parameters required by an action
-   `run` runs command-line programs using shell

Explanations of the steps:

![](https://miro.medium.com/max/700/1*Kce98VX0YywaGtA8mfMhkQ.png)

-   `Checkout` checks out your repository so that the workflow can access files in your repository
-   `Environment setup` sets up a Python environment for your workflow (I chose Python 3.8)
-   `Cache` caches dependencies so that you don’t need to install dependencies every time you run the workflow
-   `Install packages` installs all dependencies your code needs to run successfully
-   `Pull data` authenticates and pulls data from remote storage. Here, my remote storage is [DagsHub](https://towardsdatascience.com/dagshub-a-github-supplement-for-data-scientists-and-ml-engineers-9ecaf49cc505#:~:text=DagsHub%20is%20a%20platform%20for,models%2C%20experiments%2C%20and%20code.&text=The%20interface%20of%20your%20new,Notebooks%2C%20DVC%2C%20and%20Git.)

Note that it is risky to put your username and password in a script that everybody can see. Thus, we will use encrypted secrets to hide this confidential information.

#### Encrypted Secrets

Secrets are encrypted environment variables that you create in a repository. To create a secret, go to your repository, and click _Settings_ → _Secrets_ → _Actions_ → _New repository secret_.

![](https://miro.medium.com/max/700/1*1IeD3_lYiWVtoa62a4ghnA.png)

![](https://miro.medium.com/max/700/1*wx2B0GMecHvQjfY3KCZ0HA.png)

Insert the name of your secret and the value associated with this name.

![](https://miro.medium.com/max/459/1*XWj50AopXzQIfT2eE91YKw.png)

Now you can access the secret `DAGSHUB_USERNAME` using `${{ secrets.DAGSHUB_USERNAME }}` .
```yaml
steps:
  ...
  - name: Pull data
    run: |
      dvc remote modify origin --local auth basic
      dvc remote modify origin --local user ${{ secrets.DAGSHUB_USERNAME }}
      dvc remote modify origin --local password ${{ secrets.DAGSHUB_TOKEN }}
      dvc pull -r origin train_model
```

#### Run Tests

![](https://miro.medium.com/max/700/1*Prnyik5wQ2A5ciZP2NmRhw.png)

There are two parts to our code: training the model and deploying the model. We will write steps that make sure both parts can run without any errors and will work as expected.

Here is the step to test the training code:
```yaml
steps:
  ...
  - name: Run training tests
    run: pytest training/tests
```

Specifically, we test the processing code and ML model.

![](https://miro.medium.com/max/700/1*4MjAys5zC0hXvQicGwrRMg.gif)

_Find all the tests_ [_here_](https://github.com/khuyentran1401/employee-future-prediction/tree/master/training/tests)_._

The steps to test the deployment code include:

-   Save model to BentoML local store

```yaml
steps:
  ...
  - name: Save model to BentoML local store
    run: python application/src/save_model_to_bentoml.py
```

-   Run the application locally and run [tests](https://github.com/khuyentran1401/employee-future-prediction/blob/master/application/tests/test_create_service.py) to make sure the application works as we expected.

```yaml
steps:
  ...
  - name: Serve the app locally and run app tests
    run: |
      bentoml serve ./application/src/create_service.py:service  & 
      sleep 10
      pytest application/tests
      kill -9 `lsof -i:3000 -t`
```

_Note: Here, we created an ML-powered app using BentoML. Read the [previous section](bentoml.md) to understand more about BentoML:_

Add and commit this workflow to the master branch on GitHub.

```
git add .github
git commit -m 'add workflow'
git push origin master
```

#### Add Rules

To make sure the code is available to be merged **only when** the workflow runs successfully, select _Settings_ → _Branches_ → _Add rule_.

![](https://miro.medium.com/max/700/1*DrkEJHUQnk3vQ6bu_LlaNg.png)

Add `master` as the branch name pattern, check `Require status checks to pass before merging` , then add the name of the workflow under _Status checks that are required_. Finally, click _Save changes_.

![](https://miro.medium.com/max/700/1*jfziFo6HMl1qftAQTK22CQ.png)

Now when you create a pull request, GitHub Actions will automatically run the workflow `Test new model`. You won’t be able to merge the pull request if the check does not pass.

![](https://miro.medium.com/max/700/1*IGfW1WktyiNDW3oKBhf8BA.png)

Clicking _Details_ will show you the status of the run.

![](https://miro.medium.com/max/640/1*uX7VPXtVLn3rTlFP7F1Chg.gif)

Full code for testing the training code:
```yaml
name: Test new model
on:
  pull_request:
    paths:
      - config/**
      - training/**
      - application/**
      - .github/workflows/test_training.yaml
jobs:
  test_model:
    name: Test new model
    runs-on: ubuntu-latest
    steps:
      - name: Checkout 
        id: checkout
        uses: actions/checkout@v2

      - name: Environment setup
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
          cache: pip

      - name: Cache
        uses: actions/cache@v2
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/dev-requirements.txt') }}
          restore-keys: ${{ runner.os }}-pip-
        
      - name: Install packages
        run: pip install -r dev-requirements.txt

      - name: Pull data
        run: |
          dvc remote modify origin --local auth basic
          dvc remote modify origin --local user ${{ secrets.DAGSHUB_USERNAME }}
          dvc remote modify origin --local password ${{ secrets.DAGSHUB_TOKEN }}
          dvc pull -r origin train_model
      - name: Run training tests
        run: pytest training/tests

      - name: Save model to BentoML local store
        run: python application/src/save_model_to_bentoml.py

      - name: Serve the app locally and run app tests
        run: |
          bentoml serve ./application/src/create_service.py:service  & 
          sleep 10
          pytest application/tests
          kill -9 `lsof -i:3000 -t`
```

### Use GitHub Actions to Deploy Model After Merging

After merging the pull request, the model should automatically be deployed to the existing service. Let’s create a GitHub workflow to do exactly that.

Start with creating another workflow called [deploy_app.yaml](https://github.com/khuyentran1401/employee-future-prediction/blob/master/.github/workflows/deploy_app.yaml) :

```bash
.github
└── workflows
    ├── deploy_app.yaml
    └── test_model.yaml
```

The first few steps of the workflow are similar to the previous workflow:

![](https://miro.medium.com/max/700/1*Kce98VX0YywaGtA8mfMhkQ.png)

```yaml
name: Deploy App
on:
  push:
    branches:
      - master
    paths:
      - config/**
      - training/**
      - application/**
      - .github/workflows/deploy_app.yaml
jobs:
  deploy_app:
    name: Deploy App
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        id: checkout
        uses: actions/checkout@v2

      - name: Environment setup
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
          cache: pip

      - name: Cache
        uses: actions/cache@v2
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/dev-requirements.txt') }}
          restore-keys: ${{ runner.os }}-pip-

      - name: Install packages
        run: pip install -r dev-requirements.txt

      - name: Pull data
        run: |
          dvc remote modify origin --local auth basic
          dvc remote modify origin --local user ${{ secrets.DAGSHUB_USERNAME }}
          dvc remote modify origin --local password ${{ secrets.DAGSHUB_TOKEN }}
          dvc pull -r origin process_data train_model
      - name: Run and save model 
        run: python training/src/evaluate_model.py
        env:
          MLFLOW_TRACKING_USERNAME: ${{ secrets.MLFLOW_TRACKING_USERNAME }}
          MLFLOW_TRACKING_PASSWORD: ${{ secrets.MLFLOW_TRACKING_PASSWORD }} 
```

We also use `env` to add environment variables to the workflow. The environment variables will be used in some steps in the workflow.
```yaml
jobs:
  deploy_app:
    env: # Set environment variables
      HEROKU_API_KEY: ${{ secrets.HEROKU_API_KEY }}
      HEROKU_EMAIL: ${{ secrets.HEROKU_EMAIL }}
```

Next, we use [BentoML](https://towardsdatascience.com/bentoml-create-an-ml-powered-prediction-service-in-minutes-23d135d6ca76) to containerize the model and then deploy it to [Heroku](https://www.heroku.com/).

![](https://miro.medium.com/max/700/1*gb37ASDRRILsKJYe3CBFyw.png)

```yaml
steps:
  ...
  - name: Build Bentos
    run: bentoml build

  - name: Heroku login credentials
    run: |
      cat > ~/.netrc <<EOF
        machine api.heroku.com
          login $HEROKU_EMAIL
          password $HEROKU_API_KEY
        machine git.heroku.com
          login $HEROKU_EMAIL
          password $HEROKU_API_KEY
      EOF
  - name: Login to Heroku container
    run: heroku container:login

  - name: Containerize Bentos, push it to the Heroku app, and release the app
    run: |
      cd $(find ~/bentoml/bentos/predict_employee/ -type d -maxdepth 1 -mindepth 1)/env/docker
      APP_NAME=employee-predict-1
      heroku container:push web --app $APP_NAME  --context-path=../..
      heroku container:release web --app $APP_NAME
```

> [Full code for deploying the app](https://github.com/khuyentran1401/employee-future-prediction/blob/master/.github/workflows/deploy_app.yaml).

Add and commit this workflow to the master branch on GitHub.

```bash
git add .github
git commit -m 'add workflow'
git push origin master
```

Now when you merge a pull request, a workflow called `Deploy App` will run. To view the status of the workflow, click _Actions_ → Name of the latest workflow → _Deploy App_.

![](https://miro.medium.com/max/700/1*Xn0lBO9RPTLR_OAGH_iamA.png)

![](https://miro.medium.com/max/468/1*swZBvkbKvUCoejcoPVCLDA.png)

Now you should see your workflow running:

![](https://miro.medium.com/max/640/1*2w4BtvMh-jTS1LE9kT-4KA.gif)

Cool! The website for this app, which is [https://employee-predict-1.herokuapp.com/](https://employee-predict-1.herokuapp.com/), is now updated.

![](https://miro.medium.com/max/700/1*R9DjDXg0ahPbsyTWSOGUSw.png)

Since my Streamlit app makes the POST request to the URL above to generate predictions, the app is also updated.
```python
prediction = requests.post(
    "https://employee-predict-1.herokuapp.com/predict",
    headers={"content-type": "application/json"},
    data=data_json,
).text[0]
```

![](https://miro.medium.com/max/700/1*puxBBbPXeg-YEP3UhCL95g.gif)

### Conclusion

You have just learned how to use GitHub actions to create workflows that automatically test a pull request from a team member and deploy the ML model to the existing service. I hope this section will give you the motivation to automate your tasks with GitHub Actions.

### **Reference**

_Deploy to Heroku with github actions_. remarkablemark. (2021, March 12). Retrieved May 31, 2022, from [https://remarkablemark.org/blog/2021/03/12/github-actions-deploy-to-heroku/](https://remarkablemark.org/blog/2021/03/12/github-actions-deploy-to-heroku/)

Galvis, J. (2020, August 12). _Using github actions for integration testing on a REST API_. Medium. Retrieved May 31, 2022, from [https://medium.com/weekly-webtips/using-github-actions-for-integration-testing-on-a-rest-api-358991d54a20](https://medium.com/weekly-webtips/using-github-actions-for-integration-testing-on-a-rest-api-358991d54a20)

Ktrnka. (n.d.). _Ktrnka/MLOPS\_EXAMPLE\_DVC: Mlops example using DVC, S3, and Heroku_. GitHub. Retrieved May 31, 2022, from [https://github.com/ktrnka/mlops\_example\_dvc](https://github.com/ktrnka/mlops_example_dvc)

Employee Future Prediction. CC0: Public Domain. Retrieved 2022–05–10 from [https://www.kaggle.com/datasets/tejashvi14/employee-future-predictio](https://www.kaggle.com/datasets/tejashvi14/employee-future-predictio)