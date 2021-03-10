# Introduction

## Competition overview

This repository contains my final files for the M5 Forecasting - Accuracy Competition that took place from March to June 2020.

The goal of the competition was to build a model to predict 28 days of sales for 3049 of Walmart products from 3 categories and 7 departments, sold in 10 different stores across 3 states.

That's a total of 30490 times series to forecast 28 days ahead, which are evaluated also at aggregation level (state, store, category, department, state/category, state/department, store/category, store/department etc.) resulting of a total of 42840 times series.

The metric used for the evaluation is the WRMSSE (Weighted Root Mean Scaled Error).

More detail on the competition on Kaggle : [Kaggle M5 Forecasting Accuracy](https://www.kaggle.com/c/m5-forecasting-accuracy/overview)

![Forecast for California](/images/forecast_CA.png)


## My submission's score

This repository contains my solution as it was for my last submission. This solution gives a Public Score (WMRSSE) of 0.48734 and a Private Score of 0.62408, which would give a position of 190th on 5558 participants, which is in the top 4% and a silver medal for this competition.

Usually on Kaggle's competition, we are allowed 2 submissions, and we can submit a aggressive one and a more conservative one. Unfortunately for this competition, there was only one submission allowed, and I decided to use a previous submission which had a better score on the public leaderboard (0.46744), but it didn't do as well for the private score : 0.66695, which is the 385th place on 5558, which is in the top 7% and a bronze medal.

## How to use this repository

There are 2 ways :

-   I want to play:

You can use the file **m5_model_store.R** in RStudio to play with it. It's the script I used to test feature, train the algorithm, make prediction etc... It produces files for the test data and the validation data, as well as some visualizations for the prediction at department level, feature importance, and learning curve. This script produces the predictions by state, for each store. You can change the parameters at the beginning of the file to change the state. Read the instruction below to make sure you have all the pre-requisite (except the paragraph "Execute the script")

-   Give me the files:

As it takes about 8 hours to generate the predictions for all stores, I created scripts to run for all stores, the procedure is described in the instructions below. There are different models for different stores, but overall the models are the same, except for some features that where performing better on some store, and less on others.

## Principle of the algorithm

The model uses lightGBM with features based on past transactions up to the previous week.

This means that to predict the 28 days ahead, the algorithm predicts week by week for 4 weeks, and uses the predictions from the previous week to generate the new features to predict the following week.

The impact is that the first week have good predictions because it uses only the true values from the past transactions. The second week uses true values for the features that are with a lag \> 7, but uses the predicted values for the features with a lag \< 7, increasing the uncertainty, and leading to less accurate forecast for the following weeks.

To lower the impact, all the feature based on the previous week are rolling features using at least 7 days, to smooth the predictions. So the predictions are not used directly as a lag value which would give it too much importance when training the algorithm, and being too inaccurate to predict, but they are used to construct rolling features over a period of 7, 14, 28 days.

The lag values are used directly only with the real values (lag \> 28).

The rest is classic, with split between train / test / valid data. The model is trained on the train data, then predict on the test data using a weekly prediction. Then two choices :

-   re-train the model on the full dataset (train + test) to predict the validation data.
-   use the model train only on the train data, to predict the validation data (not using the month before the data to predict in the training data).

The second method worked better for the evaluation period, and is faster as the model is also trained only once. To use the first method, un-comment the corresponding part in the main section of the script.

## Technical choices

The dataset contains 30490 time series with 1941 days of history. This correspond to a dataset of 59,181,090 observations, and when adding new features, it needs a lot of memory.

I had the challenge to run it on a laptop with 16Gb of RAM, so in order to be able to test many features without running out of memory I used different techniques which can add some complexity to read the program :

-   Generate a model by store_id (10 models for validation and 10 models for evaluation)
-   Use a different script to generate the feature at aggregation level
-   Not using a framework such as MLR or Tidymodel to be able to free memory after each manipulation
-   Save objects to disk and remove them from memory to work on another object
-   Using dplyr for the first manipulation and data.table after to update by reference and avoid a copy of the variable in memory.

At the time of the competition, lightGBM was not on CRAN. I used the version 2.2.4 from the source that I compiled on my laptop. R was in version 3.6.3. You may have different results with newer versions of R and lightGBM.

You can read a more detail explanation on my website: [https://www.christophenicault.com/post/m5_forecasting_accuracy/](https://www.christophenicault.com/post/m5_forecasting_accuracy/)


# Instructions

## Directory structure

You need to keep the following directory structure :

-   data: copy all the data for the competition

-   models: contains all models

-   output:

    -   evaluation: prediction files, metrics and features importance for the evaluation period
    -   final: final predictions for the competition submission
    -   validation: prediction files, metrics and features importance for the validation period

-   wrk: contains extra data files with more feature

    -   tmp: contains the temporary files generated by the models

## Get the data

Download and copy all the data files from the competition site to the data directory

The files can be found at the following adress : [M5 Forecasting Competition files on Kaggle](https://www.kaggle.com/c/m5-forecasting-accuracy/data)

You need all the files :

-   calendar.csv
-   sales_train_validation.csv
-   sample_submission.csv
-   sell_prices.csv
-   sales_train_evaluation.csv

## Create features for the whole dataset

A model is built for each store, with only the subset of the data for this store. It's interesting to add features based on data from the other stores, states, etc. These features using all the dataset are generated only once by the script extra_data_valid.R for validation period and extra_data_eval.R for the evaluation period.

Execute both scripts (from \\processing\\pre):

-   extra_data_valid.R create the file extra_data_valid.RData in "wrk" directory
-   extra_data_eval.R create the file extra_data_eval.RData in "wrk" directory

## Execute the script

Edit the batch file store_script_valid.bat and store_script_eval.bat to change the path to your own version of R.

### For the validation period

Execute the script store_script_valid.bat

The script will call a model for each store, and generate in \\output\\validation all the files :

-   10 files M5_store_test_XX_X: prediction for the test period of the validation data
-   10 files M5_store_valid_XX_X: prediction for the validation period of the validation data
-   10 files features_XX_X: feature importance for the model
-   10 files features_XX_X: metrics for the model (RMSE for test, valid and eval)

where XX_X is the store_id

Note : On the RMSE

-   for test: when training the algorithm, the RMSE is calculated on the prediction for the valid period with all the rolling features being the true value, as it predict for the whole 28 days at once.
-   for valid: predicting the valid period, week per week using the lag from previous weeks, therefore, for week n, some feature comes from the predictions of week n-1, which will lead to prediction being less accurate.
-   for eval: predictions for the eval period, note that this metric was added when the real data have been released during the competition.

### For the evaluation period

Execute the script store_script_eval.bat

The script will call a model for each store, and generate the same files than above. For the performance, only test and valid are available as the true value for the evaluation period are not known.

## Create the final submission

from \\processing\\post:

-   The file merge_stores_valid.R generate the file "M5_validation.csv" in \\output\\validation
-   The file merge_stores_valid.R generate the file "M5_evaluation.csv" in \\output\\evaluation
-   The file merge_final.R uses the two previous file and generate the file "M5_predictions_final_2.csv" in \\output\\final
