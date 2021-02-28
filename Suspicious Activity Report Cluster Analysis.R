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



#EDA
tail(sar)
head(sar)
nrow(sar)
ncol(sar)
str(sar)
summary(sar)
cor(sar[2:8]) 
sar[is.na(sar),]



#Compute optimal number of clusters
fviz_nbclust(sar[2:8], kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2)+
  labs(subtitle = "Elbow method") #3 clusters



# Compute k-means with k = 2 and 3
km2 <- kmeans(sar[2:8], 2, nstart = 25)
print(km2)
fviz_cluster(km2, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())

km3 <- kmeans(sar[2:8], 3, nstart = 25)
print(km3)
fviz_cluster(km3, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())



#evaluate goodness of clusters - 5 clusters looks like it did better
sil <- silhouette(km2$cluster, dist(sar[2:8]))
fviz_silhouette(sil)

sil <- silhouette(km3$cluster, dist(sar[2:8]))
fviz_silhouette(sil)



#cbind clusters to the original data
clusters <- data.frame(cbind(sar, cluster = km3$cluster))
clusters$cluster <- as.factor(clusters$cluster)
head(clusters)



#Visualizing results
p <- ggparcoord(data = clusters, columns = c(2:8), groupColumn = "cluster") + labs(x = "Type", y = "value (in standard-deviation units)", title = "Clustering")
ggplotly(p)



#Export to excel to analyze cluster characteristics in Tableau
setwd("")
write.csv(clusters, "clusters.csv")

centers <- as.data.frame(km3$centers)
write.csv(centers, "centers.csv")

scale <- data.frame(scale(clusters[2:8]))
scale <- cbind(State =clusters$State, Cluster =clusters$cluster, scale)
write.csv(scale, "scale.csv")



#Hierarchical clustering for comparison
hc.res <- eclust(sar[,2:8], "hclust", k = 3, hc_metric = "euclidean", 
                 hc_method = "ward.D2", graph = FALSE)
fviz_dend(hc.res, show_labels = FALSE,
          palette = "jco", as.ggplot = TRUE)
