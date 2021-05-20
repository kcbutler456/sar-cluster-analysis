# Suspicious Activity Report (SAR) Cluster Analysis

Suspicious Activity Reports (SAR) are reports which financial instructions are required to file, according to the Bank Secrecy Act of 1970, whenever they identify suspicious or potentially suspicious activity by an account holder. The purpose of these reports is to identify individuals or organizations involved in money laundering, fraud, terrorist funding operations or any other suspicious activity out of the ordinary (Kenton, 2019). 

This project seeks to identify natural clusters in the public SAR filing data located on the Financial Crimes Enforcement Network (FinCEN) government website. This data includes aggregated totals of SARs filed by month, year, industry type, suspicious activity, state, instrument type, relationship, and regulator. As a result of the project, I'm hoping to identify specific groups or patterns in the data that highlight not only interesting criminal behavior but also potentially identify interesting SAR filing behavior. 

This is an unsupervised machine learning task which will utilize k-means and hierarchical clustering algorithms and compare the results. Suspicious activity categories including cyber event, gaming activities, identification documentation, money laundering, mortgage fraud, terrorist financing, and structuring will be used to cluster states across the nation (excluding territories). Due to the volume of the data and to maximize insight, this analysis will be limited to SAR activity filed in depository institutions and their deposit accounts in 2020. Therefore, the research question breaks down to, "what states exhibit similar suspicious activity for depository institutions in deposit accounts for 2020?".

## Tools and Resources

- R
- Tableau for EDA and presenting results
- Suspicious Activity Report (SAR) data (SAR stats, n.d.)
- United States Population Census data (Bureau, U., 2019)
- K-Means Clustering in R: Algorithm and Practical Examples (Rashmi, 2020)
- Determining The Optimal Number Of Clusters: 3 Must Know Methods (Kassambara et al., 2017)
- Evaluating goodness of clustering for unsupervised learning case (Khandelwal, 2020)

## Data Collection

Seven files were generated, due to the parameter restrictions on the website, for each suspicious activity type in depository institutions for deposit accounts in 2020: Cyber event, gaming activities, identification documentation, money laundering, mortgage fraud, terrorist financing, and structuring. 3,460,668 suspicious activity observations were collected for each state (excluding territories). United states populations statistics were then joined to the union suspicious activity file to generate per capita statistics. The below visualizations show the distribution of the raw activity per capita. This starts to highlight overall SAR filing activities across the United States. I excluded Delaware from this visualization only due to it being an extreme outlier. 

<div class='tableauPlaceholder' id='viz1621546232215' style='position: relative'><noscript><a href='#'><img alt='Suspicious Activity Distribution per Capita ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;SA&#47;SARClusterAnalysis&#47;SuspiciousActivityDistributionperCapita&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='SARClusterAnalysis&#47;SuspiciousActivityDistributionperCapita' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;SA&#47;SARClusterAnalysis&#47;SuspiciousActivityDistributionperCapita&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en' /></object></div>         

## Data Cleaning and Preparation 

- Remove irrelevant, pre-aggregated columns, and Guam territory
```html
msb$Year.Month <- NULL
msb$State <- as.factor(msb$State)
msb$Industry <- NULL
msb$Suspicious.Activity <- NULL
msb$Product <- NULL
msb$Type <- as.factor(msb$Type)
msb <- msb[msb$State != "[Total]"&msb$State!="Guam",]
```
- Aggregate count to suspicious activity type and state, and calculate per capita statistic
```html
sar <- group_by(msb,State, Type) %>%
  summarise(sum = sum(Count))
sar <- merge(sar, pop, by = "State", all.x = TRUE)
sar$capita <- (sar$sum/sar$Population)*1000
sar$sum <- NULL
sar$Population <- NULL
```
- Pivot the data for analysis and replace null values with 0
```html
sar <-  data.frame(pivot_wider(sar, names_from = c(Type), values_from = capita))
sar[is.na(sar)] = 0
sar <- data.frame(sar)
```

## Exploratory Data Analysis

A correlation matrix was used to examine the relationship among variables before analysis. 

```html
cor(sar[2:8]) 
```

![image](https://user-images.githubusercontent.com/55027593/109570774-3d86a880-7ab0-11eb-91cb-d99e6798f16a.png)

![image](https://user-images.githubusercontent.com/55027593/109570868-61e28500-7ab0-11eb-9320-97ab0f22ae3e.png)


## Optimal K Cluster Selection

I started the machine learning phase by identifying the optimal number of clusters for analysis. I used the elbow method as they call it. It searches for the optimal number of clusters by minimizing the total within-cluster sum of squares or compactness. 

```html
fviz_nbclust(sar[2:8], kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2)+
  labs(subtitle = "Elbow method") #3 clusters
```
![image](https://user-images.githubusercontent.com/55027593/119052475-4342aa80-b98a-11eb-8a67-37dbeba5b755.png)

## Clustering and evaluating goodness of cluster

Based on the results from the "elbow" method of determining the best number of clusters, I wanted to compare how the k-means algorithm does with two and three clusters. After analyzing the results (presented below), I decided to continue with three clusters for analysis. Additionally, I scanned the results from the hierarchical clustering method. It produced similar results. 

```html
km2 <- kmeans(sar[2:8], 2, nstart = 25)
print(km2)
fviz_cluster(km2, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())
```

![image](https://user-images.githubusercontent.com/55027593/119052788-be0bc580-b98a-11eb-94e4-efa20f348134.png)

![image](https://user-images.githubusercontent.com/55027593/119052536-5a819800-b98a-11eb-9c9b-4eb8851825b9.png)

```html
sil <- silhouette(km2$cluster, dist(sar[2:8]))
fviz_silhouette(sil)

```
![image](https://user-images.githubusercontent.com/55027593/119053211-5d30bd00-b98b-11eb-8cca-ab504414f714.png)

![image](https://user-images.githubusercontent.com/55027593/119053127-3e322b00-b98b-11eb-898a-ccb56a702248.png)

```html
km3 <- kmeans(sar[2:8], 3, nstart = 25)
print(km3)
fviz_cluster(km3, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())
```


![image](https://user-images.githubusercontent.com/55027593/119053377-99fcb400-b98b-11eb-9aea-73e1130efc7a.png)

![image](https://user-images.githubusercontent.com/55027593/109572436-cd2d5680-7ab2-11eb-85b9-8b2e7538eb30.png)


```html
sil <- silhouette(km3$cluster, dist(sar[2:8]))
fviz_silhouette(sil)
```
![image](https://user-images.githubusercontent.com/55027593/119053445-b13ba180-b98b-11eb-9ea1-753b7aaefeac.png)

![image](https://user-images.githubusercontent.com/55027593/119053485-bbf63680-b98b-11eb-9dde-f6add37f462d.png)



```html
km4 <- kmeans(sar[2:8], 4, nstart = 25)
print(km4)
fviz_cluster(km4, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())
```
![image](https://user-images.githubusercontent.com/55027593/119053575-ddefb900-b98b-11eb-8de2-440c6617a1f4.png)

![image](https://user-images.githubusercontent.com/55027593/119053612-ee079880-b98b-11eb-8fe2-cb7b80e2ab70.png)

```html
sil <- silhouette(km4$cluster, dist(sar[2:8]))
fviz_silhouette(sil)
```
![image](https://user-images.githubusercontent.com/55027593/119053681-04adef80-b98c-11eb-932c-96f490edde47.png)

![image](https://user-images.githubusercontent.com/55027593/119053719-1394a200-b98c-11eb-94aa-80be84a66de6.png)


```html
hc.res <- eclust(sar[,2:8], "hclust", k = 3, hc_metric = "euclidean", 
                 hc_method = "ward.D2", graph = FALSE)
fviz_dend(hc.res, show_labels = FALSE,
          palette = "jco", as.ggplot = TRUE)
```

![image](https://user-images.githubusercontent.com/55027593/109572821-81c77800-7ab3-11eb-82db-78cb11a16fa2.png)



## Results and Conclusion

The k-means clustering algorithm successfully found three distinct clusters of states across the United States based on per capita statistic in 2020 for Depository Institutions and their deposit accounts.

** Interactive dashboard: https://public.tableau.com/profile/kristina.butler8425#!/vizhome/SARClusterAnalysis/SARClusterAnalysis

<div class='tableauPlaceholder' id='viz1621546810393' style='position: relative'><noscript><a href='#'><img alt='SAR Cluster Analysis ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;SA&#47;SARClusterAnalysis&#47;SARClusterAnalysis&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='SARClusterAnalysis&#47;SARClusterAnalysis' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;SA&#47;SARClusterAnalysis&#47;SARClusterAnalysis&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en' /></object></div>  

![image](https://user-images.githubusercontent.com/55027593/119052277-f9f25b00-b989-11eb-9669-ffe0be6bf188.png)


The obvious and most glaring cluster is cluster 3 and only contains one state: Delaware. Upon investigation, I found Delaware is quite known for their business or corporate conducive environment. It is attractive to business owners due to its business-friendly usury laws and light taxation (Tarver, 2021). In fact, before 2017, there were more business registered in Delaware than the total population (Bartels, 2019). Additionally, and more importantly, this state has local laws in place that allow private businesses to protect the identity of their owners (Tarver, 2021). In other words, businesses in Delaware are able to hide the true beneficiary owner for the company. This is a major issue when it comes to anti-money laundering efforts. For example, if a financial institution does not know who the beneficiary owner is of the company, it makes it harder to determine legitimate operations from shell companies. This allows criminals easier access to launder money in the financial system. From the chart below, we can see Delaware has significant SAR filing data in money laundering, identification documentation, and gaming activities.  

![image](https://user-images.githubusercontent.com/55027593/119052124-b992dd00-b989-11eb-85bc-bff621216a30.png)

Looking at the other two clusters, we can start to uncover an interesting filing trend. Cluster 1, overall, seems to have more filing activity making them the higher suspicious activity filing per capita cluster. Additionally, these states usually have a peak in one area of suspicious activity. Cluster 2 can be considered the lower suspicious activity filing per capita cluster with the majority of the data points falling within expected criminal and SAR filing behavior ranges (with the exception of Alaska in gaming activities). Based on what we learned in cluster 3 about beneficial ownership and the laws that exist in Delaware, we can start to see how the laws might be playing a role in the peaks of type of activity that is filed in cluster 1. Additionally, we can start to uncover patters in the type of crime distributed across the United States. For example, South Dakota is significantly higher in terrorist financing, North Carolina in mortgage fraud, and Ohio in cyber event activity.

![image](https://user-images.githubusercontent.com/55027593/119051908-6caf0680-b989-11eb-9d63-7ca291474e76.png)

![image](https://user-images.githubusercontent.com/55027593/119052025-936d3d00-b989-11eb-9d60-94a318814635.png)


## References

- Kenton, W. (2020, September 09). Suspicious activity report (sar) definition. Retrieved February 28, 2021, from https://www.investopedia.com/terms/s/suspicious-activity-report.asp
- Rashmi, Kassambara 06 May 2020 The demo data used in this tutorial is available in the default installation of R. Juste type data(“USArrests”) Reply, &amp; Kassambara. (2018, October 21). K-Means clustering in R: Algorithm and practical examples. Retrieved February 28, 2021, from https://www.datanovia.com/en/lessons/k-means-clustering-in-r-algorith-and-practical-examples/
- Kassambara, Visitor, Kassambara, Visitor_Luigi, Fdtd, &amp; Visitor_Ann. (2017, September 07). Determining the optimal number of clusters: 3 must know methods. Retrieved February 28, 2021, from http://www.sthda.com/english/articles/29-cluster-validation-essentials/96-determiningthe-optimal-number-of-clusters-3-must-know-methods/
- SAR stats. (n.d.). Retrieved February 28, 2021, from https://www.fincen.gov/reports/sar-stats
- Bureau, U. (2019, December 30). State population Totals: 2010-2019. Retrieved February 28, 2021, from https://www.census.gov/data/tables/time-series/demo/popest/2010s-state-total.html#par_textimage_1574439295
- Khandelwal, R. (2020, December 07). Evaluating goodness of clustering for unsupervised learning case. Retrieved February 28, 2021, from https://towardsdatascience.com/evaluating-goodness-of-clustering-for-unsupervised-learning-case-ccebcfd1d4f1
- Tarver, E. (2021, January 01). Why Delaware is considered a tax shelter. Retrieved March 02, 2021, from https://www.investopedia.com/articles/personal-finance/092515/4-reasons-why-delaware-considered-tax-shelter.asp
- Bartels, J. (2019, April 06). Discreet Delaware: Why corporate secrecy and money LAUNDERING have thrived in the US. Retrieved March 02, 2021, from https://www.biia.com/discreet-delaware-why-corporate-secrecy-and-money-laundering-have-thrived-in-the-us
