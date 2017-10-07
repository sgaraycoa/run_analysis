
#download and unzip folder
file<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(file, "./data/samsungdata.zip", method="curl")
unzip("./data/samsungdata.zip", exdir="./data")

#load datasets to R 
test<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest<-read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")
train<-read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain<-read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")
activity<-read.table("./data/UCI HAR Dataset/activity_labels.txt")[,2]
activity<-as.list(activity)


#labeling columns
colnames<-read.table("./data/UCI HAR Dataset/features.txt")[,2]
names(test)<-colnames
names(train)<-colnames
names(subject_test)<-"subject"
names(subject_train)<-"subject"

#extracting only mean and sd of each measurement
meansd<-grepl("mean|std",  colnames)
test<-test[,meansd]
train<-train[,meansd]
test<-test[,!grepl("meanFreq", names(test))]
train<-train[,!grepl("meanFreq", names(train))]

#merging datasets
test<-cbind(subject_test, ytest, test)
train<-cbind(subject_train, ytrain, train)
library(dplyr)
data<-rbind(test, train)

#making activity a factor var with appropriate labels
data<-rename(data, activity=V1)
activity_labels<-c("walking", "walking upstairs", "walking downstairs", "sitting", "standing", "laying")
data$activity<-factor(data$activity, levels=1:6, labels=activity_labels) 

#cleaning up var names
names(data)<-tolower(names(data))
names(data)<-gsub("-mean\\(\\)","mean",names(data))
names(data)<-gsub("-std\\(\\)","std",names(data))
names(data)<-gsub("-","",names(data))
names(data)<-sub("^t","time",names(data))
names(data)<-sub("^f","freq",names(data))
names(data)<-gsub("bodybody","body",names(data))


##Step 5
detach("package:dplyr", unload=TRUE)
library(plyr)
varmeans<-function(data){colMeans(data[,-c(1,2)])}
tidydata<-ddply(data, .(subject, activity), varmeans)

#notice that the output table is 180 rows long (30 subjects x 6 activities)
write.table(tidydata, file= "./Getting and Cleaning Data/run_analysis/tidydata.txt", row.name=FALSE)