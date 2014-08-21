README.md
===


Preamble
---

The assignment deals with the data collected from the accelerometers of the Samsung Galaxy S smartphone. The data pertain to the
["Human Activity Recognition Using Smartphones Data Set" project](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
from the "UC Irvine Machine Learning Repository"

Here the activities to perform:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

To have an idea of the data organisation, let's do a quick overview of the structure (folders are shown in bold).
Between parentheses a short description of the files/folders is given, as well as the dimensions of the data contained in each file (rows & columns).

>+ **UCI HAR Dataset** _(root folder)_
>	+ **test** _(test data folder)_
>		+ **Inertial Signals** _(test inertial signals folder)_
>
			+ body\_acc\_x\_test.txt _(X axis body acceleration - `2947x128`)_
			+ body\_acc\_y\_test.txt _(Y axis body acceleration - `2947x128`)_
			+ body\_acc\_z\_test.txt _(Z axis body acceleration - `2947x128`)_
			+ body\_gyro\_x\_test.txt _(X orthogonal angular velocity - `2947x128`)_
			+ body\_gyro\_y\_test.txt _(Y orthogonal angular velocity - `2947x128`)_
			+ body\_gyro\_z\_test.txt _(Z orthogonal angular velocity - `2947x128`)_
			+ total\_acc\_x\_test.txt _(X axis acceleration signal - `2947x128`)_
			+ total\_acc\_y\_test.txt _(Y axis acceleration signal - `2947x128`)_
			+ total\_acc\_z\_test.txt _(Z axis acceleration signal - `2947x128`)_
>			
>		+ subject\_test.txt _(2947 test volunteers ids for each observation of the test data set - `2947x1`)_
>		+ X\_test.txt _(2947 observations of the 561 features of the test data set - `2947x561`)_
>		+ y\_test.txt _(2947 activity ids for each observation of the test data set - `2947x1`)_
>
>	+ **train** _(train data folder)_
>		+ **Inertial Signals** _(train inertial signals folder)_
>
			+ body\_acc\_x\_train.txt _(X axis body acceleration - `7352x128`)_
			+ body\_acc\_y\_train.txt _(Y axis body acceleration - `7352x128`)_
			+ body\_acc\_z\_train.txt _(Z axis body acceleration - `7352x128`)_
			+ body\_gyro\_x\_train.txt _(X orthogonal angular velocity - `7352x128`)_
			+ body\_gyro\_y\_train.txt _(Y orthogonal angular velocity - `7352x128`)_
			+ body\_gyro\_z\_train.txt _(Z orthogonal angular velocity - `7352x128`)_
			+ total\_acc\_x\_train.txt _(X axis acceleration signal - `7352x128`)_
			+ total\_acc\_y\_train.txt _(Y axis acceleration signal - `7352x128`)_
			+ total\_acc\_z\_train.txt _(Z axis acceleration signal - `7352x128`)_
>			
>		+ subject\_train.txt _(7352 train volunteers ids for each observation of the train data set - `7352x1`)_
>		+ X\_train.txt _(7352 observations of the 561 features of the train data set - `7352x561`)_
>		+ y\_train.txt _(7352 activity ids for each observation of the train data set - `7352x1`)_
>
>	+ activity\_labels.txt _(list of the 6 measured activities labels - `6x2`)_
>	+ features.txt _(list of the 561 features built as specified in the features\_info.txt file - `561x2`)_
>	+ features\_info.txt _(description pattern of the features selection - `descriptive`)_
>	+ README.txt _(README.txt file - `descriptive`)_

The whole data structure, unless inertial signals folders, are shown in the picture below:

![UCI HAR Dataset](https://coursera-forum-screenshots.s3.amazonaws.com/ab/a2776024af11e4a69d5576f8bc8459/Slide2.png "UCI HAR Dataset diagram")

###### Picture source: [David's post](https://class.coursera.org/getdata-006/forum/search?q=Slide2.png#12-state-query=Slide2.png) on coursera's "Getting and Cleaning Data" forum


Initial assumptions
---

+ The data contained in the inertial signals folders aren't used for the assignment, therefore they won't be included in the
script, nor the data set.

+ We assume that the data for the project, was already [downloaded](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
and unzipped **in the same folder of the *analysis.R* file**.

+ It is necessary to set the working directory **to the script file location**. The structure of the data must remain unchanged.

+ All the details on the fields of the resulting data frame, are contained in the `CodeBook.md` file (that file will be produced with the _analysis.R_ script).

+ All the transformations and work, performed to clean up the data, are reported in this document.

+ By running the "analysis.R" script, the "user" will create:

	+ a tidy data frame (`full_DF`)
	+ a "filtered" data frame (`mean_sd_DF`), with means and standard deviation
	+ an output file named ***agg_mean_DF.txt*** with the aggregated data
	+ an output file named ***CodeBook.md*** with the details on the data frame fields


Roadmap
---

Unlike the steps stated in the project description, I followed an alternative order to satisfy the project's requirements.

Here the steps that will be orderly followed:

+ Preliminary step: Clean the environment and set the working directory
+ Step 1: Merge the train and test data sets
+ Step 2: Tidy the full data set
	+ Substep 2a: Set proper columns names
	+ Substep 2b: Add proper names to descriptive variables
+ Step 3: Tidy data set
+ Step 4: Extract the first work data set (mean and standard deviation)
+ Step 5: Extract the second work data set (average)
+ Add on: Script to produce contents for the CodeBook


Preliminary step: Clean the environment and set the working directory
---

In this section we prepare the environment by cleaning previously used objects and setting the working directory.

	rm(list=ls())

	#set the working directory at the same path of this script

Step 1: Merge the train and test data sets
---

The purpose of this section is to create a unique data set by merging the data contained in the files:

+ subject\_&lt;type&gt;.txt
+ X\_&lt;type&gt;.txt
+ y\_&lt;type&gt;.txt

where the tag &lt;type&gt; can take the values "test" or "train" depending on the partition we consider.

	<type> = {test;train}

The merging procedure is similar for both partitions, so we can illustrate it in a general way using the &lt;type&gt; tag.

The only difference will be the number of rows we're dealing with. For the "test" partition we'll have 2497 observations while for the "train" partition
we'll have 7352.

To keep the generalization we'll call &lt;N&gt; the number of observations for the partition we consider.

	<N> = {2497;7352}

First we shall save each file path:

	X_<type>_url <- "./UCI HAR Dataset/<type>/X_<type>.txt"
	
	y_<type>_url <- "./UCI HAR Dataset/<type>/y_<type>.txt"
	
	subject_<type>_url <- "./UCI HAR Dataset/<type>/subject_type>.txt"

and use each path with the `read.table()` function to load the data: 

	X_<type> <- read.table(X_<type>_url)

	y_<type> <- read.table(y_<type>_url)

	subject_<type> <- read.table(subject_<type>_url)

To optimize the time to load the *X\_&lt;type&gt;.txt* file (the heaviest one) we can set the classes of the columns
as stated in the code of the _#preload to find column classes_ section:

	#preload to find column classes
	initial_<type> <- read.table(X_<type>_url, nrows = 1)
	classes_<type> <- sapply(initial_<type>, class)

_N.B: on the `run_analysis.R` file there are also a few lines of code to check the dimensions of the freshly loaded variables._

Once the files are loaded in their data frames we can merge them by using the `cbind()` function.
To easily manage the 561 columns of the _X\_&lt;type&gt;.txt_ files against the labels description in the 561 features in the _features.txt_ file, we choose
to concatenate the files with the following structure:

first **X\_&lt;type&gt;.txt** then **y\_&lt;type&gt;.txt** and last **subject\_&lt;type&gt;.txt**
 
In terms of rows and columns we have a `Nx561 - Nx1 - Nx1` data frame: N rows and 563 columns. Where the first 561st columns are the values of the features for the data set,
while the 562nd column is the activity id and the 563rd is the volunteer id.

Here's the piece of code: `<type>_DF <- cbind(X_<type>,y_<type>,subject_<type>)`

Finally by repeating the same procedure for the other partition we obtains both "column-merged" sets.

The last step to do is to merge those two _&lt;type&gt;\_DF_ data frames by rows, with the function `rbind()`.
We choose to append the _train_ partition after the _test_ partition to keep the tree order depicted in the Preamble.

Here's the piece of code: `full_DF <- rbind(test_DF,train_DF))`

To make a check on our work, we can find the dimensions of the resulting data frame with the code:

`paste("DIM full data set: rows",dim(full_DF)[1],"cols",dim(full_DF)[2])`.

As expected we obtain a ***10299x563*** data frame.


Step 2: Tidy the full data set
---

The purpose of this section is to "clean" the resulting data frame obtained in the precedent step.

###Substep 2a: Set proper columns names

First we shall name properly the columns of the data frame that consists in 563 column.

From left to right we have: 

+ the first 561st columns that contains the values of each feature specified in the file _features.txt_

By looking at the _features.txt_ file we see that each record is related to a string. To update the default name of the columns in
the `full_DF` data frame we applied a loop over the 561 records. We choose for simplicity to keep exactly the same values contained in
the _features.txt_ (that's why parenthesis, hyphens and all sort of extra alfanumeric characters are still present in the columns names of the data frame).
The only modification was to "prefix" the original column name (eg: V543) with the _features.txt_ file values.
We judged that keeping the number of the original column, linked to the row of the _features.txt_ file, could be useful in the future to easily find a particular feature.

The final column name will then be in the form:

	<original_col_name>-<column name from the feature file>

Clearly every row in the _features.txt_ file corresponds to its respective column in the `full_DF` data frame.

Here's the piece code of the for loop:

	#add columns labels 1 to 561
	features_url <- "./UCI HAR Dataset/features.txt"
	features <- read.table(features_url)
	
	#loop through every data frame column between the first and the 561st
	for(i in 1:561) {
			colnames(full_DF)[i] <-	as.character(paste0(colnames(full_DF)[i],"-",features[i,2]))       
	}

In the body of the for loop we chose to use the `paste0()` function as it is more efficient while removing extraspaces between the arguments.

Also to correctly implement the string name of the particular column the function `as.character()` was needed
while assigning the columns names of the data frame.

Finally we chose to explicitly specify the loop range (1:561) to have more control over the assigned vector
values, because we have 2 furthers columns in the data frame. In that manner we're sure to don't overlap while looping.

+ the 562nd and 563rd column contains respectively the activity id and the volunteer id

For both columns we did a simple column assignment as indicated in the following piece of code:

	#add columns labels 562 and 563
	colnames(full_DF)[562] <- "activityID"
	colnames(full_DF)[563] <- "volunteerID"
	
We can then check the overall data frame with the new columns names with:

	#check columns names of the full_DF data set
	colnames(full_DF)
	
Here's a preview:

	[1] "V1#tBodyAcc-mean()-X"
	[2] "V2#tBodyAcc-mean()-Y"
	[3] "V3#tBodyAcc-mean()-Z"
	[4] "V4#tBodyAcc-std()-X" 
	...
	[560] "V560#angle(Y,gravityMean)"                
	[561] "V561#angle(Z,gravityMean)"                
	[562] "activityID"                               
	[563] "volunteerID" 

###Substep 2b: Add proper names to descriptive variables

The descriptive names are available for the "activityID" column, where for each integer value, we have a corresponding string of the particularly
activity done by the volunteer. To decode the activity we simply refer to the _activity\_labels.txt_ file.

We chose to keep the original value (the one contained in "activityID" column), because it could be useful for further analysis since it's already
in a integer form. Consequently we only need to add a new column to the `full_DF` data frame: the new column will be named "activityLABEL".

We chose to proceed by duplicating the existing activityID. This will increment the columns dimensions by 1, our data frame will become `10299x564`.
After we rename the added column, by using the `sub()` function replaced every activityLABEL value with it corresponding
value read in the _activity\_labels.txt_ file.

Here's the code that implement the request:

	#Substep 2b: Add proper names to descriptive variables

	activity_labels_url <- "./UCI HAR Dataset/activity_labels.txt"
	activity_labels <- read.table(activity_labels_url)

	#duplicate activityID column and rename it in activityLABEL
	full_DF <- cbind(full_DF,full_DF$activityID)
	colnames(full_DF)[564] <- "activityLABEL"
	
	#loop through every activity and update the value in the activityLABEL
	for(i in 1:6) {
			full_DF$activityLABEL <- 
					sub(i, activity_labels[i,2],full_DF$activityLABEL,fixed=TRUE)
	}

	
Step 3: Tidy data set
---
	
In these section we simply indicate the final data frame of the tidy data set.

	paste0("The output of the run_analysis.R script produced a tidy data set that",
	" has ", nrow(full_DF)," obervations of ", ncol(full_DF)," variables.")

The output of the _run\_analysis.R_ script is contained in the `full_DF` data frame, that has 10299 observations of 564 variables.

	
Step 4: Extract the first work data set (mean and standard deviation)
---

The requirement of this step was to "_extract only the measurements on the mean and standard deviation for each measurement_". 

By looking at the _features\_info.txt_ file we can see that two groups of vectors were estimated:

+ the first by applying some function to the signals (for what we are interested in, the `mean()` and `std()` functions)
+ the second by averaging the signals in a signal window sample (used on the `angle()` variable)

Based on our (basic) knowledge of the UCI HAR project, we assumed that both groups features should be extracted for the first work data set.

Here's the piece of code that extracts the list of columns (optionnaly saved to a text file):

	#select the vector of features that match the requirements
	V_mean_sd <- grep("[Mm]ean|[Ss][Tt][Dd]", names(full_DF))

	#save the list of features in a text file
	#write(names(full_DF[,V_mean_sd]),"extracted_mean_std_features.txt")

And here's the [output](data:text/plain;base64,VjEtdEJvZHlBY2MtbWVhbigpLVgNClYyLXRCb2R5QWNjLW1lYW4oKS1ZDQpWMy10Qm9keUFjYy1tZWFuKCktWg0KVjQtdEJvZHlBY2Mtc3RkKCktWA0KVjUtdEJvZHlBY2Mtc3RkKCktWQ0KVjYtdEJvZHlBY2Mtc3RkKCktWg0KVjQxLXRHcmF2aXR5QWNjLW1lYW4oKS1YDQpWNDItdEdyYXZpdHlBY2MtbWVhbigpLVkNClY0My10R3Jhdml0eUFjYy1tZWFuKCktWg0KVjQ0LXRHcmF2aXR5QWNjLXN0ZCgpLVgNClY0NS10R3Jhdml0eUFjYy1zdGQoKS1ZDQpWNDYtdEdyYXZpdHlBY2Mtc3RkKCktWg0KVjgxLXRCb2R5QWNjSmVyay1tZWFuKCktWA0KVjgyLXRCb2R5QWNjSmVyay1tZWFuKCktWQ0KVjgzLXRCb2R5QWNjSmVyay1tZWFuKCktWg0KVjg0LXRCb2R5QWNjSmVyay1zdGQoKS1YDQpWODUtdEJvZHlBY2NKZXJrLXN0ZCgpLVkNClY4Ni10Qm9keUFjY0plcmstc3RkKCktWg0KVjEyMS10Qm9keUd5cm8tbWVhbigpLVgNClYxMjItdEJvZHlHeXJvLW1lYW4oKS1ZDQpWMTIzLXRCb2R5R3lyby1tZWFuKCktWg0KVjEyNC10Qm9keUd5cm8tc3RkKCktWA0KVjEyNS10Qm9keUd5cm8tc3RkKCktWQ0KVjEyNi10Qm9keUd5cm8tc3RkKCktWg0KVjE2MS10Qm9keUd5cm9KZXJrLW1lYW4oKS1YDQpWMTYyLXRCb2R5R3lyb0plcmstbWVhbigpLVkNClYxNjMtdEJvZHlHeXJvSmVyay1tZWFuKCktWg0KVjE2NC10Qm9keUd5cm9KZXJrLXN0ZCgpLVgNClYxNjUtdEJvZHlHeXJvSmVyay1zdGQoKS1ZDQpWMTY2LXRCb2R5R3lyb0plcmstc3RkKCktWg0KVjIwMS10Qm9keUFjY01hZy1tZWFuKCkNClYyMDItdEJvZHlBY2NNYWctc3RkKCkNClYyMTQtdEdyYXZpdHlBY2NNYWctbWVhbigpDQpWMjE1LXRHcmF2aXR5QWNjTWFnLXN0ZCgpDQpWMjI3LXRCb2R5QWNjSmVya01hZy1tZWFuKCkNClYyMjgtdEJvZHlBY2NKZXJrTWFnLXN0ZCgpDQpWMjQwLXRCb2R5R3lyb01hZy1tZWFuKCkNClYyNDEtdEJvZHlHeXJvTWFnLXN0ZCgpDQpWMjUzLXRCb2R5R3lyb0plcmtNYWctbWVhbigpDQpWMjU0LXRCb2R5R3lyb0plcmtNYWctc3RkKCkNClYyNjYtZkJvZHlBY2MtbWVhbigpLVgNClYyNjctZkJvZHlBY2MtbWVhbigpLVkNClYyNjgtZkJvZHlBY2MtbWVhbigpLVoNClYyNjktZkJvZHlBY2Mtc3RkKCktWA0KVjI3MC1mQm9keUFjYy1zdGQoKS1ZDQpWMjcxLWZCb2R5QWNjLXN0ZCgpLVoNClYyOTQtZkJvZHlBY2MtbWVhbkZyZXEoKS1YDQpWMjk1LWZCb2R5QWNjLW1lYW5GcmVxKCktWQ0KVjI5Ni1mQm9keUFjYy1tZWFuRnJlcSgpLVoNClYzNDUtZkJvZHlBY2NKZXJrLW1lYW4oKS1YDQpWMzQ2LWZCb2R5QWNjSmVyay1tZWFuKCktWQ0KVjM0Ny1mQm9keUFjY0plcmstbWVhbigpLVoNClYzNDgtZkJvZHlBY2NKZXJrLXN0ZCgpLVgNClYzNDktZkJvZHlBY2NKZXJrLXN0ZCgpLVkNClYzNTAtZkJvZHlBY2NKZXJrLXN0ZCgpLVoNClYzNzMtZkJvZHlBY2NKZXJrLW1lYW5GcmVxKCktWA0KVjM3NC1mQm9keUFjY0plcmstbWVhbkZyZXEoKS1ZDQpWMzc1LWZCb2R5QWNjSmVyay1tZWFuRnJlcSgpLVoNClY0MjQtZkJvZHlHeXJvLW1lYW4oKS1YDQpWNDI1LWZCb2R5R3lyby1tZWFuKCktWQ0KVjQyNi1mQm9keUd5cm8tbWVhbigpLVoNClY0MjctZkJvZHlHeXJvLXN0ZCgpLVgNClY0MjgtZkJvZHlHeXJvLXN0ZCgpLVkNClY0MjktZkJvZHlHeXJvLXN0ZCgpLVoNClY0NTItZkJvZHlHeXJvLW1lYW5GcmVxKCktWA0KVjQ1My1mQm9keUd5cm8tbWVhbkZyZXEoKS1ZDQpWNDU0LWZCb2R5R3lyby1tZWFuRnJlcSgpLVoNClY1MDMtZkJvZHlBY2NNYWctbWVhbigpDQpWNTA0LWZCb2R5QWNjTWFnLXN0ZCgpDQpWNTEzLWZCb2R5QWNjTWFnLW1lYW5GcmVxKCkNClY1MTYtZkJvZHlCb2R5QWNjSmVya01hZy1tZWFuKCkNClY1MTctZkJvZHlCb2R5QWNjSmVya01hZy1zdGQoKQ0KVjUyNi1mQm9keUJvZHlBY2NKZXJrTWFnLW1lYW5GcmVxKCkNClY1MjktZkJvZHlCb2R5R3lyb01hZy1tZWFuKCkNClY1MzAtZkJvZHlCb2R5R3lyb01hZy1zdGQoKQ0KVjUzOS1mQm9keUJvZHlHeXJvTWFnLW1lYW5GcmVxKCkNClY1NDItZkJvZHlCb2R5R3lyb0plcmtNYWctbWVhbigpDQpWNTQzLWZCb2R5Qm9keUd5cm9KZXJrTWFnLXN0ZCgpDQpWNTUyLWZCb2R5Qm9keUd5cm9KZXJrTWFnLW1lYW5GcmVxKCkNClY1NTUtYW5nbGUodEJvZHlBY2NNZWFuLGdyYXZpdHkpDQpWNTU2LWFuZ2xlKHRCb2R5QWNjSmVya01lYW4pLGdyYXZpdHlNZWFuKQ0KVjU1Ny1hbmdsZSh0Qm9keUd5cm9NZWFuLGdyYXZpdHlNZWFuKQ0KVjU1OC1hbmdsZSh0Qm9keUd5cm9KZXJrTWVhbixncmF2aXR5TWVhbikNClY1NTktYW5nbGUoWCxncmF2aXR5TWVhbikNClY1NjAtYW5nbGUoWSxncmF2aXR5TWVhbikNClY1NjEtYW5nbGUoWixncmF2aXR5TWVhbikNCg==) with the 86 features that satisfy the requirements.
The last seven rows of the output, are referred to the second group of vectors estimated.

To obtain the desired data set we should add to the vector of selected features, the columns of the _activityID_, _volunteerID_ and _activityLABEL_ variables.
We chose to add those columns in leftmost part of the data frame.

This could be done by issuing the following statement:

	#create the required data frame by prefixing with the 3 additional columns of
	#activities and volunteers
	mean_sd_DF <- full_DF[,c(
		grep("activityID", colnames(full_DF)),
		grep("volunteerID", colnames(full_DF)),
		grep("activityLABEL", colnames(full_DF)),
		V_mean_sd)]

	#dim(mean_sd_DF)
	
The resulting data frame `mean_sd_DF` has 10299 observations of 89 variables.


Step 5: Extract the second work data set (average)
---

The requirement of this step was to "_create a second, independent tidy data set with the average of each variable for each activity and each subject_". 

By reading the requirement we understood that "_each variable_" have to be taken. Therefore we considered _each variable_ and _then_ and aggregated
the data by mean. It is not explicitly stated that we should "pre-select" some variables and then aggregate and computing the mean.

We computed the `aggregate()` function by using first the 561st variables (the "features")and after of the `full_DF`, as well as 
the "activityLABEL" and "volunteerID" fields.

The piece of code that implement that is:

	#aggregate the full_DF in a new DF with the average of each variable
	#for each activity and each subject
	attach(full_DF)
	agg_mean_DF <- aggregate(full_DF[,(1:561)],
                        by=list(full_DF$activityLABEL,full_DF$volunteerID),
                        FUN="mean")
	detach(full_DF)

Finally we exported the data in an external text file using the `write.table()` function:

	#export the data on text file
	write.table(agg_mean_DF,"agg_mean_DF.txt",row.names=FALSE)

The resulting data frame `agg_mean_DF` has 180 rows and 563 columns.
	
Add on: Script to produce contents for the CodeBook
---

The codebook was created by following the guidelines of the sample file contained in the first question of Quiz 1, as well as the suggestions of the course forum.

Basically the informations pertains the fields of the tidy data set `full_DF`, and have been structured in the following manner:

##### Field &lt;id of the field&gt;: &lt;label of the field&gt;
##### &bull; _Maximum width:_ &lt;value&gt;
##### &bull; _Minimum width:_ &lt;value&gt;
##### &bull; _Values range from_ &lt;value&gt; _to_ &lt;value&gt;

Since the tidy data set has over 500th fields, We built the Code Book using `R`. Essentially we built a heading, several "blocks" using the for loop, and a footer.

Here's the code:

	#Add on: Script to produce contents for the CodeBook

	#output file name
	output_file<- "CodeBook.md"

	#headers lines of the CodeBook file
	write("CodeBook",file=output_file)
	write("===",file=output_file,append=TRUE)
	write("",file=output_file,append=TRUE)
	write("Preamble",file=output_file,append=TRUE)
	write("---",file=output_file,append=TRUE)
	write("This CodeBook contains the data dictionnary of the
	\"Getting and Cleaning Data\" assignment (getdata-006 course).",
		  file=output_file,append=TRUE)

	#loop through every data frame field (minus the last one to retrieve
	#code book contents
	for(i in 1:(ncol(full_DF)-1)) {
			
			write("",file=output_file,append=TRUE)
			write(paste0("## Field ",i,": ",colnames(full_DF)[i]),
				  file=output_file, append=TRUE)
			write(paste0("+ _Maximum width:_ ",max(nchar(full_DF[,i]))),
				  file=output_file, append=TRUE)
			write(paste0("+ _Minimum width:_ ",min(nchar(full_DF[,i]))),
				  file=output_file, append=TRUE)
			
			write(paste0("+ _Values range from_ ",
				  sprintf(as.character(full_DF[which.min(full_DF[,i]),i]))," _to_ ",
				  sprintf(as.character(full_DF[which.max(full_DF[,i]),i]))),
				  file=output_file, append=TRUE)
	}

	#specify the last field
	i <- 564
	write("",file=output_file,append=TRUE)
	write(paste0("## Field ",i,": ",colnames(full_DF)[i]),
		  file=output_file,append=TRUE)
	write(paste0("+ _Maximum width:_ ",max(nchar(full_DF[,i]))),
		  file=output_file,append=TRUE)
	write(paste0("+ _Minimum width:_ ",min(nchar(full_DF[,i]))),
		  file=output_file,append=TRUE)
	write("+ _Values range:_ values can take any of the activities labeled in
		  the activity_labels.txt file",
		  file=output_file,append=TRUE)


