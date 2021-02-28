# Suspicious Activity Report (SAR) Cluster Analysis

*hook for storytelling - preventing money laudering??*

Suspicious Activity Reports (SAR) are reports which financial instructions are required to file, according to the Bank Secrecy Act of 1970, whenever they identify suspicious or potentially suspicious activity by an account holder. The purpose of these reports is to identify individuals or organizations involved in money laundering, fraud, terrorist funding operations or any other suspicious activity out of the ordinary (Kenton, 2019). 

This project seeks to identify natural clusters in the public SAR filing data located on the Financial Crimes Enforcement Network (FinCEN) government website. This data includes aggregated totals of SARs filed by month, year, industry type, suspicious activity, state, instrument type, relationship, and regulator. As a result of the project, I'm hoping to identify specific groups or patterns in the data that highlight not only interesting criminal behavior but also potentially identify interesting SAR filing behavior. 

This is an unsupervised machine learning task which will utilize k-means and hierarchical clustering algorithms and compare the results. Suspicious activity categories including cyber event, gaming activities, identification documentation, money laundering, mortgage fraud, and structuring will be used to cluster states across the nation (excluding territories). Due to the volume of the data and in an effort to maximize insight, this analysis will be limited to SAR activity filed in depository institutions and their deposit accounts in 2020. Therefore, the research question breaks down to, "what states exhibit similar suspicious activity for depository institutions in deposit accounts for 2020?".

## Tools and Resources

- R
- Tableau for EDA and presenting results
- Suspicious Activity Report (SAR) data (SAR stats, n.d.)
- United States Population Census data (Bureau, U., 2019)
- K-Means Clustering in R: Algorithm and Practical Examples (Rashmi, 2020)
- Determining The Optimal Number Of Clusters: 3 Must Know Methods (Kassambara et al., 2017)
- Evaluating goodness of clustering for unsupervised learning case (Khandelwal, 2020)

## Data Collection

Six files were generated for each suspicious activity type in depository institutions for deposit accounts in 2020; Cyber event, gaming activities, identification documnetation, money laundering, mortgage fraud, and structuring. 1,707,991 suspicious activity observations were collected for each state (excluding territories). United states populations statistics were then joined to the unioned supsicious activity file to generate per capita statistics. 

![image](https://user-images.githubusercontent.com/55027593/109431922-79494180-79ce-11eb-8085-98ff18ac6aff.png)


## Data Cleaning and Prepartion 

## EDA and Feature Selection

## Optimial K Cluster Selection

## Clustering 

## Results and Conclusion


## References

- Kenton, W. (2020, September 09). Suspicious activity report (sar) definition. Retrieved February 28, 2021, from https://www.investopedia.com/terms/s/suspicious-activity-report.asp
- Rashmi, Kassambara 06 May 2020 The demo data used in this tutorial is available in the default installation of R. Juste type data(“USArrests”) Reply, &amp; Kassambara. (2018, October 21). K-Means clustering in R: Algorithm and practical examples. Retrieved February 28, 2021, from https://www.datanovia.com/en/lessons/k-means-clustering-in-r-algorith-and-practical-examples/
- Kassambara, Visitor, Kassambara, Visitor_Luigi, Fdtd, &amp; Visitor_Ann. (2017, September 07). Determining the optimal number of clusters: 3 must know methods. Retrieved February 28, 2021, from http://www.sthda.com/english/articles/29-cluster-validation-essentials/96-determiningthe-optimal-number-of-clusters-3-must-know-methods/
- SAR stats. (n.d.). Retrieved February 28, 2021, from https://www.fincen.gov/reports/sar-stats
- Bureau, U. (2019, December 30). State population Totals: 2010-2019. Retrieved February 28, 2021, from https://www.census.gov/data/tables/time-series/demo/popest/2010s-state-total.html#par_textimage_1574439295
- Khandelwal, R. (2020, December 07). Evaluating goodness of clustering for unsupervised learning case. Retrieved February 28, 2021, from https://towardsdatascience.com/evaluating-goodness-of-clustering-for-unsupervised-learning-case-ccebcfd1d4f1
