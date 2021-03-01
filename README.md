# Suspicious Activity Report (SAR) Cluster Analysis

*hook*

Suspicious Activity Reports (SAR) are reports which financial instructions are required to file, according to the Bank Secrecy Act of 1970, whenever they identify suspicious or potentially suspicious activity by an account holder. The purpose of these reports is to identify individuals or organizations involved in money laundering, fraud, terrorist funding operations or any other suspicious activity out of the ordinary (Kenton, 2019). 

This project seeks to identify natural clusters in the public SAR filing data located on the Financial Crimes Enforcement Network (FinCEN) government website. This data includes aggregated totals of SARs filed by month, year, industry type, suspicious activity, state, instrument type, relationship, and regulator. As a result of the project, I'm hoping to identify specific groups or patterns in the data that highlight not only interesting criminal behavior but also potentially identify interesting SAR filing behavior. 

This is an unsupervised machine learning task which will utilize k-means and hierarchical clustering algorithms and compare the results. Suspicious activity categories including cyber event, gaming activities, identification documentation, money laundering, mortgage fraud, terrorist financing, and structuring will be used to cluster states across the nation (excluding territories). Due to the volume of the data and in an effort to maximize insight, this analysis will be limited to SAR activity filed in depository institutions and their deposit accounts in 2020. Therefore, the research question breaks down to, "what states exhibit similar suspicious activity for depository institutions in deposit accounts for 2020?".

## Tools and Resources

- R
- Tableau for EDA and presenting results
- Suspicious Activity Report (SAR) data (SAR stats, n.d.)
- United States Population Census data (Bureau, U., 2019)
- K-Means Clustering in R: Algorithm and Practical Examples (Rashmi, 2020)
- Determining The Optimal Number Of Clusters: 3 Must Know Methods (Kassambara et al., 2017)
- Evaluating goodness of clustering for unsupervised learning case (Khandelwal, 2020)

## Data Collection

Seven files were generated for each suspicious activity type in depository institutions for deposit accounts in 2020; Cyber event, gaming activities, identification documnetation, money laundering, mortgage fraud, terrorist financing, and structuring. 3,460,668 suspicious activity observations were collected for each state (excluding territories). United states populations statistics were then joined to the unioned supsicious activity file to generate per capita statistics. The below visualizations shows the distribution of the raw activity per capita. This starts to highlight overall SAR filing activities across the United States. 

<div class='tableauPlaceholder' id='viz1614638548488' style='position: relative'><noscript><a href='#'><img alt=' ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Su&#47;SuspiciousActivityperCapita&#47;Dashboard1&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='SuspiciousActivityperCapita&#47;Dashboard1' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Su&#47;SuspiciousActivityperCapita&#47;Dashboard1&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en' /><param name='filter' value='publish=yes' /></object></div>           
          

## Data Cleaning and Prepartion 

- Remove irrelevant, reaggregated columns, and Guam territory
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

## Exploratory Data Analysis and Feature Selection

Insurance 

```html
cor(sar[2:8]) 
```

![image](https://user-images.githubusercontent.com/55027593/109433930-676c9c00-79d8-11eb-8dd2-1afe6ad9437e.png)

## Optimial K Cluster Selection

```html
fviz_nbclust(sar[2:8], kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2)+
  labs(subtitle = "Elbow method") #3 clusters
```
![image](https://user-images.githubusercontent.com/55027593/109433959-8e2ad280-79d8-11eb-926c-f55a7d74d90f.png)

## Clustering 

Compare 2 and 3 clusters

```html
km2 <- kmeans(sar[2:8], 2, nstart = 25)
print(km2)
fviz_cluster(km2, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())
```
![image](https://user-images.githubusercontent.com/55027593/109433995-c16d6180-79d8-11eb-9792-307ba873f337.png)

![image](https://user-images.githubusercontent.com/55027593/109433980-b1558200-79d8-11eb-86a5-c8168d9bec02.png)


```html
km3 <- kmeans(sar[2:8], 3, nstart = 25)
print(km3)
fviz_cluster(km3, data = sar[2:8],
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw())
```
![image](https://user-images.githubusercontent.com/55027593/109434012-cf22e700-79d8-11eb-8efd-18ccbb9e6569.png)

![image](https://user-images.githubusercontent.com/55027593/109434019-d77b2200-79d8-11eb-9e08-c67750b17917.png)


##Evaluate goodness of clusters


```html
sil <- silhouette(km2$cluster, dist(sar[2:8]))
fviz_silhouette(sil)

```
![image](https://user-images.githubusercontent.com/55027593/109434062-02fe0c80-79d9-11eb-96fa-7ebd79159321.png)

![image](https://user-images.githubusercontent.com/55027593/109434066-06919380-79d9-11eb-9148-2bb1abb3050b.png)

```html
sil <- silhouette(km3$cluster, dist(sar[2:8]))
fviz_silhouette(sil)
```
![image](https://user-images.githubusercontent.com/55027593/109434086-1e691780-79d9-11eb-9861-631973f6090d.png)

![image](https://user-images.githubusercontent.com/55027593/109434076-0f826500-79d9-11eb-92b2-b66aa49e72b5.png)


## Results and Conclusion
## References

- Kenton, W. (2020, September 09). Suspicious activity report (sar) definition. Retrieved February 28, 2021, from https://www.investopedia.com/terms/s/suspicious-activity-report.asp
- Rashmi, Kassambara 06 May 2020 The demo data used in this tutorial is available in the default installation of R. Juste type data(“USArrests”) Reply, &amp; Kassambara. (2018, October 21). K-Means clustering in R: Algorithm and practical examples. Retrieved February 28, 2021, from https://www.datanovia.com/en/lessons/k-means-clustering-in-r-algorith-and-practical-examples/
- Kassambara, Visitor, Kassambara, Visitor_Luigi, Fdtd, &amp; Visitor_Ann. (2017, September 07). Determining the optimal number of clusters: 3 must know methods. Retrieved February 28, 2021, from http://www.sthda.com/english/articles/29-cluster-validation-essentials/96-determiningthe-optimal-number-of-clusters-3-must-know-methods/
- SAR stats. (n.d.). Retrieved February 28, 2021, from https://www.fincen.gov/reports/sar-stats
- Bureau, U. (2019, December 30). State population Totals: 2010-2019. Retrieved February 28, 2021, from https://www.census.gov/data/tables/time-series/demo/popest/2010s-state-total.html#par_textimage_1574439295
- Khandelwal, R. (2020, December 07). Evaluating goodness of clustering for unsupervised learning case. Retrieved February 28, 2021, from https://towardsdatascience.com/evaluating-goodness-of-clustering-for-unsupervised-learning-case-ccebcfd1d4f1
