# Analysisng COVID-19

## Outline

### Software

1. R >= 3.6
2. R Studio >= 1.2
3. Python >= 3.6
4. Anaconda

### Strategy

* Social media data is huge.
  * 250m tweets per day on Twitter.
  * Facebook and Instagram have higher volume depending ion content.
* Decision based on
  * Purpose of project.
  * Resources
    * Cloud
    * PC
  * Time

### Why Twitter

* Facebook limits its API and collection of data.
* Instagram is also limited.
* **Twitter has open policy and is popular among researchers**.

### Social Media Data Collection

* **API method**: Using username and API tokens - R (*rtweet*)
* **Non API method**: Using keyword query search - Python (*GetOldTweets3*)

### Social Media Data Analysis

* Sentiment analysis
* Network analysis

---

## Data

### Source

John Hopkins University CSSE [Novel Coronavirus (COVID-19) Cases data](https://systems.jhu.edu/research/public-health/ncov/): https://github.com/CSSEGISandData/COVID-19

### Tracking

Covid Tracking Projects: https://covidtracking.com

### Keywords

```
#COVID19
#covid19
#coronavirus
#CoronaVirus
#coronavirustexas
#Coronavirustexas
#coronavirusnewyork
#coronaviruscalifornia
```

# Social Media Data Collection and Analytics

## I. Using API Method to collect Twitter data

Acquire API key and token from [Twitter developer website](http://dev.twitter.com) 
1. Login using your Twitter account (create one if none exists)
2. Click on Apps, create an app and apply for a developer account.  Give detail on your purpose (e.g. personal research)

Sample description:

1. Using API to conduct public opinion research.
2. Analyze Tweet contents, trends and transactional data in social networks.
3. Focus on Tweeting, favorites/likes, following and retweeting will be involved
4. Aggregate data will be presented to the public and reviewing agency targeting publications in academic journals and presentations in academic conferences.

Once approved, Twitter will provide API detail in four keys/secret/tokens. Open an R session and store the API data:

```
## Create token for direct authentication to access Twitter data

token <- rtweet::create_token(
  app = "Your App name",
  consumer_key <- "YOURCONSUMERKEY",
  consumer_secret <- "YOURCONSUMERSECRET",
  access_token <- "YOURACCESSTOKEN",
  access_secret <- "YOURACCESSSECRET")

## Check token

rtweet::get_token()
```


With API methods, there are plenty of R packages for collecting Twitter data.  Examples include twitteR, vosonSML and rtweet.  The following illustration uses rtweet, which gives most detail in twitter variables (> 90). 

```
## Install packages need for Twitter data download

install.packages(c("rtweet","igraph","tidyverse","ggraph","data.table"), repos = "https://cran.r-project.org")

## Load packages

library(rtweet)
library(igraph)
library(tidyverse)
library(ggraph)
library(data.table)

## Search for 1,000 tweets in English
# Not run: 
rdt <- rtweet::search_tweets(q = "realDonaldTrump", n = 1000, lang = "en")
# End(Not run)

## preview users data
users_data(rdt)

## Boolean search for large quantity of tweets (which could take a while)
rdt <- rtweet::search_tweets(
  "Trump OR president OR potus", n = 10000,
  retryonratelimit = TRUE
)

## plot time series of tweets frequency
ts_plot(rdt, by = "mins")
```

# ![time series](https://raw.githubusercontent.com/datageneration/smdca/master/twittertimeseries.png)









## II. Using non-API Method to collect Twitter data

Twitter API is not without limits. These limits vary over time and it currently allows one week's data.  Some packages can reach data within a shorter period due to data size.  Other methods have been developed to collect historical Twitter data.  [Jefferson Henrique](https://github.com/Jefferson-Henrique/GetOldTweets-python) and [Dimtry Mottl](https://github.com/Mottl/GetOldTweets3) python packages are illustrated here.  This non-API method scrapes Twitter data based on Twitter search results by parsing the result page with a scroll loader, then calling to a JSON provider. While theoretically it can search through oldest tweets and collect data accordingly, the number of variables are limited to the layout of search results.

Prerequesites: 

1. Python3
2. Bash/terminal command line tool
3. Python pip package installer

Illustration using [GetOldTweets3](https://pypi.org/project/GetOldTweets3/) in MacOS
Install Python 3.x (e.g. Anaconda3) and run the following preparation steps (creating virtual environment, install GetOldTweets3 package using pip):
```
python3 -m venv env
source ./env/bin/activate 
python3 -m pip install GetOldTweets3
```

Alternatively, 

```
pip3 install -e git+https://github.com/Mottl/GetOldTweets3#egg=GetOldTweets3
```

There are two methods of collecting Twitter data.  The GetOldTweets3 command method is recommended since the data collection process can be time-consuming.

Examples:

```
## Keyword search
GetOldTweets3 --querysearch "Trump Kim" --since 2018-01-01 --until 2019-01-16 --output trumpkim.csv

## username search with time period and size limit

GetOldTweets3 --username "realDonaldTrump" --since 2016-11-01 --until 2020-02-29 --maxtweets 20000 --output rdt_2016_now.csv
```

The following procedures are for Windows users (Python2.x or Python 3.x):

Prerequisites

1. Python installed
  - Install  Anaconda Navigator (http://anaconda.com) 
  - Install Python from python.org

2. Visit the following github by Nickson Weng and download the Python package Get-Old_Tweet-Modified

https://github.com/NicksonWeng/Get-Old-Tweet-Modified

a. Click on the "Clone or Download" green button on right side
b. Download ZIP to local folder (e.g. c:\\Twitterdata)
c. Unzip the files to the folder

2. Open a terminal windows by typing terminal in the "Type here to search" box. Choose the Command Prompt App

3. Change directory to c:\\Twitterdata
4. Type:

pip install -r requirements.txt

Perform search using the following criteria (username or keyword)


Examples:

```{bash eval=FALSE, include=TRUE}
## Keyword search
python Exporter.py --querysearch "coronavirus" --maxtweets 100 --output coronavirus.csv

# Get Twitter data by username
python Exporter.py --username "realDonaldTrump" --maxtweets 100 --output dt_100.csv

# Get Twitter data by keyword search, with dates and geographic location
python Exporter_py3.py --querysearch "coronavirus" --since 2020-02-01 --until 2020-02-28 --near "Dallas, TX" --maxtweets 1000 --output coronavirus_1000.csv
```


## III. Sentiment analysis using TextBlob

```
install.packages("remotes")
library(reticulate)
# Install from github (development source)
remotes::install_github("news-r/textblob")
library(textblob)
# Download corpora
textblob::download_corpora() 
TG=text_blob("President Trump is nice guy.")
TG$sentiment
ctext=cvrs$text
head(ctext)
csent=text_blob(cvrs$text)
```

## IV. Network analysis
![](https://raw.githubusercontent.com/datageneration/smdca/master/Retweet_coronavirus.png)


```
## Create igraph object from Twitter data using user id and mentioned id.
## ggraph draws the network graph in different layouts (12). 
filter(rdt, retweet_count > 0 ) %>% 
  select(screen_name, mentions_screen_name) %>%
  unnest(mentions_screen_name) %>% 
  filter(!is.na(mentions_screen_name)) %>% 
  graph_from_data_frame() -> rdt_g
V(rdt_g)$node_label <- unname(ifelse(degree(rdt_g)[V(rdt_g)] > 20, names(V(rdt_g)), "")) 
V(rdt_g)$node_size <- unname(ifelse(degree(rdt_g)[V(rdt_g)] > 20, degree(rdt_g), 0)) 
ggraph(rdt_g, layout = 'kk') + 
  geom_edge_arc(edge_width=0.1, aes(alpha=..index..)) +
  geom_node_label(aes(label=node_label, size=node_size),
                  label.size=0, fill="#ffffff66", segment.colour="light blue",
                  color="red", repel=TRUE, family="Apple Garamond") +
  coord_fixed() +
  scale_size_area(trans="sqrt") +
  labs(title="Tweets about Trump", subtitle="Edges=volume of retweets. Screenname size=influence") +
  theme_graph(base_family="Apple Garamond") +
  theme(legend.position="none") 
```


To explore the network structure of the Twitter data, [igraph](http://kateto.net/networks-r-igraph) and [ggraph](https://www.data-imaginist.com/2017/ggraph-introduction-layouts/) packages are recommended for network plots 
