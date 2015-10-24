
library(dplyr)

# clear environment variables 
rm(list = setdiff(ls(), lsf.str()))

#if we haven't got a copy of the data, download it
if(!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")) download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', "getdata-projectfiles-UCI HAR Dataset.zip")

#load labels
features <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/features.txt"))
activityLabels <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/activity_labels.txt"))
colnames(activityLabels)<-c("id","activity")

#load test data
testX <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/test/X_test.txt"))
testY <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/test/y_test.txt"))
testSubjectTest <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/test/subject_test.txt"))

#load training data
trainX <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/train/X_train.txt"))
trainY <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/train/y_train.txt"))
trainSubjectTrain <- read.table(unz("getdata-projectfiles-UCI HAR Dataset.zip", "UCI HAR Dataset/train/subject_train.txt"))


#combine activity with subject for tests
testSA<-cbind(testSubjectTest,testY)
colnames(testSA)<-c("Subject","ActivityID")

#add the activity labels
test<-merge(testSA,activityLabels,by.x="ActivityID",by.y="id")[,2:3]
colnames(testX)<-features[,2]

#create new column labelling this data as the "test" set
test$set="test"
test<-cbind(test,testX)

# combine activity with subjects for training
trainSA<-cbind(trainSubjectTrain,trainY)
colnames(trainSA)<-c("Subject","ActivityID")

#add the activity labels
train<-merge(trainSA,activityLabels,by.x="ActivityID",by.y="id")[,2:3]
colnames(trainX)<-features[,2]

#create new column labelling this data as the "training" set
train$set="train"
train<-cbind(train,trainX)

#combine test and training data
alldata<-rbind(train,test)

#only choose columns relating to mean and standard deviation
means<-grep("mean\\(\\)",colnames(alldata))
stddevs<-grep("std\\(\\)",colnames(alldata))
q2<-c(c(1,2,3),means,stddevs)
q2data<-alldata[,q2]

#group by activity and subject and give the mean for each set
q5<-q2data[-3] %>% group_by(activity,Subject)  %>% summarise_each(funs(mean))

#write the table to disk
write.table(q5,file="q5.txt",row.name=FALSE)
