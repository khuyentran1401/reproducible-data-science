# Test Data

Let’s say your company is training a machine learning model to predict whether a user will click an ad or not using the data collected from users. In September 2021, the model you trained correctly predict whether a user clicked an ad 90% of the time. Hooray!

However, in October 2021, the same model correctly predict whether a user clicked an ad only 70% of the time. What happened?

![](https://miro.medium.com/max/1000/1*NRULCRnrGKDMf4D1Q6cYSQ.png)

You suspected that the change in the performance of your model might be due to the change in your data. So you decided to compare the distribution of daily time spent on site of the data collected in September 2021 and one collected in October 2021.

![](https://miro.medium.com/max/700/1*fX7dj47Yd99bQep0w4o6Zg.png)

And you were right! There is a significant difference in the distribution of the daily time spent on site between the two data.

![](https://miro.medium.com/max/700/1*kysVtQj3tlHd6C16PehWTg.png)

Since the daily time spent on site is one of the most important features in your model, the shift in the distribution of this feature leads to a drop in the performance of your model.

Instead of manually checking whether there is a change in the distribution of your data every month, is there a way that you can automatically check for the change in the distribution before the data is being fed to the model?

![](https://miro.medium.com/max/1000/1*bSf8SxM6abTeZzdi_3koxA.png)

In this chapter, you will learn some libraries to validate your data in Python.