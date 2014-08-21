##########################
## START run_analysis.R ##
##########################

#Getting and Cleaning Data - Assignment

#Please read the document README.MD to have further informations about
#this script.

#In this script several activities are done to manipulate the data collected
#from the accelerometers of.

#-------------------------------------------------------------------------------

#Preliminary step: Clean the environment, and set the working directory

rm(list=ls())

#set the working directory at the same path of this script


#Step 1: Merge the train and test data sets

#test set
X_test_url <- "./UCI HAR Dataset/test/X_test.txt"
y_test_url <- "./UCI HAR Dataset/test/y_test.txt"
subject_test_url <- "./UCI HAR Dataset/test/subject_test.txt"

#preload to find column classes
initial_test <- read.table(X_test_url, nrows = 1)
classes_test <- sapply(initial_test, class)

#load test data and check dimensions
X_test <- read.table(X_test_url, colClasses = classes_test)
y_test <- read.table(y_test_url)
subject_test <- read.table(subject_test_url)

paste("DIM X_test: rows",dim(X_test)[1],"cols",dim(X_test)[2])
paste("DIM y_test: rows",dim(y_test)[1],"cols",dim(y_test)[2])
paste("DIM subject_test: rows",dim(subject_test)[1],"cols",dim(subject_test)[2])

#column merge of test set and check dimensions
test_DF <- cbind(X_test,y_test,subject_test)
paste("DIM test data set: rows",dim(test_DF)[1],"cols",dim(test_DF)[2])

#train set
X_train_url <- "./UCI HAR Dataset/train/X_train.txt"
y_train_url <- "./UCI HAR Dataset/train/y_train.txt"
subject_train_url <- "./UCI HAR Dataset/train/subject_train.txt"

#preload to find column classes
initial_train <- read.table(X_train_url, nrows = 1)
classes_train <- sapply(initial_train, class)

#load test data and check dimensions
X_train <- read.table(X_train_url, colClasses = classes_train)
y_train <- read.table(y_train_url)
subject_train <- read.table(subject_train_url)

paste("DIM X_train: rows",dim(X_train)[1],"cols",dim(X_train)[2])
paste("DIM y_train: rows",dim(y_train)[1],"cols",dim(y_train)[2])
paste("DIM subject_train: rows",dim(subject_train)[1],"cols",dim(subject_train)[2])

#column merge of train set and check dimensions
train_DF <- cbind(X_train,y_train,subject_train)
paste("DIM train data set: rows",dim(train_DF)[1],"cols",dim(train_DF)[2])

#full set
#row merge and check dimensions
full_DF <- rbind(test_DF,train_DF)
paste("DIM full data set: rows",dim(full_DF)[1],"cols",dim(full_DF)[2])


#Step 2: Tidy the full data set

#Substep 2a: Set proper columns names

#add columns labels 1 to 561
features_url <- "./UCI HAR Dataset/features.txt"
features <- read.table(features_url)
#loop through every data frame column between the first and the 561st
for(i in 1:561) {
        colnames(full_DF)[i] <-
                as.character(paste0(colnames(full_DF)[i],"-",features[i,2]))       
}

#add columns labels 562 and 563
colnames(full_DF)[562] <- "activityID"
colnames(full_DF)[563] <- "volunteerID"

#check columns names of the full_DF data set
#colnames(full_DF)

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


#Step 3: Tidy data set
        
paste0("The output of the run_analysis.R script produced a tidy data set that",
       " has ", nrow(full_DF)," obervations of ", ncol(full_DF)," variables.")


#Step 4: Extract the first work data set (mean and standard deviation)

#select the vector of features that match the requirements
V_mean_sd <- grep("[Mm]ean|[Ss][Tt][Dd]", names(full_DF))

#save the list of features in a text file
#write(names(full_DF[,V_mean_sd]),"extracted_mean_std_features.txt")

#create the required data frame by prefixing with the 3 additional columns of
#activities and volunteers
mean_sd_DF <- full_DF[,c(
        grep("activityID", colnames(full_DF)),
        grep("volunteerID", colnames(full_DF)),
        grep("activityLABEL", colnames(full_DF)),
        V_mean_sd)]

#dim(mean_sd_DF)


#Step 5: Extract the second work data set (average)

#aggregate the full_DF in a new DF with the average of each variable
#for each activity and each subject
attach(full_DF)
agg_mean_DF <- aggregate(full_DF[,(1:561)],
                        by=list(full_DF$activityLABEL,full_DF$volunteerID),
                        FUN="mean")
detach(full_DF)

#export the data on text file
write.table(agg_mean_DF,"agg_mean_DF.txt",row.name=FALSE)

#dim(agg_mean_DF)


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

########################
## END run_analysis.R ##
########################