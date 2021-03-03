library("dplyr")
library("tidyr")
library("factoextra")
library("NbClust")
library("corrplot")
library("PerformanceAnalytics")
library("broom")
library("cluster")
library("GGally")
library("plotly")

#import the data
setwd("")
pop <- read.csv("Population.csv", header = T)
colnames(pop) <- c("State", "Population")

setwd("")
myfiles = list.files(pattern="*.csv", full.names=TRUE)
msb2 <- lapply(myfiles, read.csv)

  #Clean up data type for union
msb2[1][[1]]$Count <- as.numeric(gsub(',','',as.character(msb2[1][[1]]$Count)))
msb2[2][[1]]$Count <- as.numeric(gsub(',','',as.character(msb2[2][[1]]$Count)))
msb2[3][[1]]$Count <- as.numeric(gsub(',','',as.character(msb2[3][[1]]$Count)))
msb2[4][[1]]$Count <- as.numeric(gsub(',','',as.character(msb2[4][[1]]$Count)))
msb2[5][[1]]$Count <- as.numeric(gsub(',','',as.character(msb2[5][[1]]$Count)))
msb2[6][[1]]$Count <- as.integer(gsub(',','',as.character(msb2[6][[1]]$Count)))
msb2[7][[1]]$Count <- as.integer(gsub(',','',as.character(msb2[7][[1]]$Count)))
msb <-bind_rows(msb2) #union


#Data cleaning and preparation
msb$Year.Month <- NULL
msb$State <- as.factor(msb$State)
msb$Industry <- NULL
msb$Suspicious.Activity <- NULL
msb$Product <- NULL
msb$Type <- as.factor(msb$Type)
msb <- msb[msb$State != "[Total]"&msb$State!="Guam",] #remove aggregated rows

  #aggregate the needed fields and calculate per capita statistic
sar <- group_by(msb,State, Type) %>%
  summarise(sum = sum(Count))
sar <- merge(sar, pop, by = "State", all.x = TRUE)
sar$capita <- (sar$sum/sar$Population)*1000
sar$sum <- NULL
sar$Population <- NULL

  #pivot for analysis
sar <-  data.frame(pivot_wider(sar, names_from = c(Type), values_from = capita)) #pivot Suspicious Activity type field for clustering
sar[is.na(sar)] = 0 #replace null values
sar <- data.frame(sar)

View(sar)

#EDA
tail(sar) #check the bottom 
head(sar) #check the top
nrow(sar) #expected row = 52 for 52 states
ncol(sar) 
str(sar) #check data types
sar[is.na(sar),] #check for null values
summary(sar) #check the distribution of each variable

cor(sar[2:8]) #check for covariance
pairs(sar[,2:8], lower.panel = NULL)




#Compute optimal number of clusters with the `elbow` method
fviz_nbclust(sar[2:8], kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2)+
  labs(subtitle = "Elbow method") #3 clusters


# Compute k-means with k = 2 and 3 and 4
set.seed(123)
km2 <- kmeans(sar[2:8], 2, nstart = 25) #compactness 81%
print(km2)
fviz_cluster(km2, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())

km3 <- kmeans(sar[2:8], 3, nstart = 25) #compactness 92%
print(km3)
fviz_cluster(km3, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())

km4 <- kmeans(sar[2:8], 4, nstart = 25) #compactness 97%
print(km4)
fviz_cluster(km4, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())


#evaluate goodness of clusters and evaluating hierarchical clusters
sil <- silhouette(km2$cluster, dist(sar[2:8]))
fviz_silhouette(sil)

sil <- silhouette(km3$cluster, dist(sar[2:8]))
fviz_silhouette(sil)

sil <- silhouette(km4$cluster, dist(sar[2:8]))
fviz_silhouette(sil)


  #Hierarchical clustering for comparison
hc.res <- eclust(sar[,2:8], "hclust", k = 3, hc_metric = "euclidean", 
                 hc_method = "ward.D2", graph = FALSE)
fviz_dend(hc.res, show_labels = FALSE,
          palette = "jco", as.ggplot = TRUE)



#cbind clusters to the original data
clusters <- data.frame(cbind(sar, cluster = km3$cluster))
clusters$cluster <- as.factor(clusters$cluster)
head(clusters)


#Visualizing results
p <- ggparcoord(data = clusters, columns = c(2:8), groupColumn = "cluster") + labs(x = "Type", y = "value (in standard-deviation units)", title = "Clustering")
ggplotly(p)


#Export to excel to explore and analyze cluster characteristics in Tableau
setwd("")
write.csv(clusters, "clusters.csv")

centers <- as.data.frame(km3$centers)
write.csv(centers, "centers.csv")

scale <- data.frame(scale(clusters[2:8]))
scale <- cbind(State =clusters$State, Cluster =clusters$cluster, scale)
write.csv(scale, "scale.csv")
