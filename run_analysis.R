## This R script performs the following actions:
## 1. Download and unzip the project input archive
## 2. Merges the training and the test sets to create one data set
## 3. Extracts only the measurements on the mean and standard deviation for each measurement
## 4. Uses descriptive activity names to name the activities in the data set
## 5. Appropriately labels the data set with descriptive variable names
## 6. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

# Load plyr library (make sure it's installed)
library(plyr)

# Download the project input dataset
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./Dataset.zip", method = "curl")

# Unzip the archive
zipF<- "./Dataset.zip"
outDir<-"./"
unzip(zipF,exdir=outDir)

# Merge train and test datasets

# Read and merge X dataset
Xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
Xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
Xtotal <- rbind(Xtrain, Xtest)

# Read and merge Y dataset
Ytrain <- read.table("./UCI HAR Dataset/train/Y_train.txt")
Ytest <- read.table("./UCI HAR Dataset/test/Y_test.txt")
Ytotal <- rbind(Ytrain, Ytest)

# Read and merge S dataset
Strain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
Stest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
Stotal <- rbind(Strain, Stest)

# Prepare the datasets

# Prepare the X dataset
# Read column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
# Assign column names
names(Xtotal) <- features
# Search for mean and standard deviation measurements
features_mean_std <- grep("-mean|-std", features)
# Keep only mean and standard deviation measurements
Xtotal <- Xtotal[,features_mean_std]
# Format column names
names(Xtotal) <- gsub("\\(|\\)","",names(Xtotal))
names(Xtotal) <- gsub("-","",names(Xtotal))
names(Xtotal) <- tolower(names(Xtotal))

# Prepare the Y dataset
# Format column name
names(Ytotal) <- c("activityid")

# Prepare the S dataset
# Format column name
names(Stotal) <- c("subjectid")

# Set activity labels
# Read activity labels
activityLabel <- read.table("./UCI HAR Dataset/activity_labels.txt")
# Set column names
names(activityLabel) <- c("activityid","activity")
# Substitute activity id with activity label in the Y data set
Ytotal[['activityid']] <- activityLabel[match(Ytotal[['activityid']], activityLabel[['activityid']] ) , 'activity']

# Merge all datasets
Mtotal <- cbind(Stotal,Ytotal,Xtotal)

# Export the final dataset to text file
write.table(Mtotal,"finaldataset.txt")

# Export the tidy dataset to text file (required in step 5 of the assignment)
tidydataset <- ddply(Mtotal, .(subjectid,activityid), .fun=function(x){colMeans(x[,3:ncol(Mtotal)])})
write.table(tidydataset,"tidydataset.txt", row.names = FALSE)
