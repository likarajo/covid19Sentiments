# Analysing COVID-19

## Outline

### Software

1. R >= 3.6
2. R Studio >= 1.2
3. Python >= 3.6
4. Anaconda

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

---

## Data Collection

### I. Non-API Method using Python

```
Twitter API has limits which vary over time and currently allows one week's data. Some packages allow to collect historical Twitter data. 
```
Package used here: [GetOldTweets3](https://pypi.org/project/GetOldTweets3/) 
* [Jefferson Henrique](https://github.com/Jefferson-Henrique/GetOldTweets-python)
* [Dimtry Mottl](https://github.com/Mottl/GetOldTweets3) 

This non-API method scrapes Twitter data based on Twitter search results by parsing the result page with a scroll loader, then calling to a JSON provider. While theoretically it can search through oldest tweets and collect data accordingly, the number of variables are limited to the layout of search results.

1. Creating virtual environment and install *GetOldTweets3* package using pip
```bash
python3 -m venv env
source ./env/bin/activate 
python3 -m pip install GetOldTweets3
```

Alternatively, 
```bash
pip3 install -e git+https://github.com/Mottl/GetOldTweets3#egg=GetOldTweets3
```

2. Collecting Twitter data.
```bash
## Keyword search
GetOldTweets3 --querysearch "Coronavirus" --since 2020-02-01 --until 2020-03-25 --output data/corona_0325.csv

## username search with time period and size limit
GetOldTweets3 --username "realDonaldTrump" --since 2020-02-01 --until 2020-03-25 --maxtweets 20000 --output data/corona_0325_rdt.csv
```

### II. API Method using R

1. Acquire API key and token from [Twitter developer website](https://dev.twitter.com) 
2. Install and load the required R package(s) for collecting and vizualizing Twitter data. Examples: *rtweet, twitteR, vosonSML*. *rtweet* gives most detail in twitter variables (> 90). 
```
rtweet, ggmap, igraph, tidyverse, ggraph, ggplot2, data.table, maps, mapdata
```
3. Store and check the API keys/tokens
4. Check token
5. Search using query
6. Preview data
7. Time series plot

---

## Sentiment analysis using TextBlob

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

---

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
