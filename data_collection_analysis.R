## Corona virus data collection

# Install packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(rtweet, ggmap, igraph, tidyverse, ggraph, ggplot2, data.table, maps, mapdata)

# Load packages
library(rtweet)
library(ggmap) # Google map now requires API key
library(igraph)
library(tidyverse)
library(ggraph)
library(ggplot2)
library(data.table)
library(maps)
library(mapdata)

# Store API keys/tokens
token <- rtweet::create_token(
  app = "COVID19",
  consumer_key <- "K84vFz3AgKTdWnnnHqAeW9LSJ",
  consumer_secret <- "a02zgGUTE8fIe564FB7IiHLZA8RBupFEch56uPKG9sn9fctzQD",
  access_token <- "2390269165-IkElqrvtb2fH6fQwlH9yV7BN4aZNOdJtOG4SjCn",
  access_secret <- "DQAsk7p7FLY9RSHKKnyflQYi0xuTeU3U8AHd3ysqUDWbA")

## Check keys/tokens
rtweet::get_token()

## User search
#rdt_user <- rtweet::search_users(q = "realDonaldTrump", n = 1000)
#rdt_fn <- lookup_users("realDonaldTrump")
#rdt_f <- get_followers("realDonaldTrump", n = rdt_fn$followers_count, retryonratelimit = TRUE)

## Query Search for coronavirus
cvrs <- rtweet::search_tweets("Coronavirus OR coronavirus OR COVID19 OR covid19, lang:en", 
                              n = 500, retryonratelimit = TRUE)

## Time series plot
ts_plot(cvrs, by = "mins") + theme_bw()
  
## Keyword search

cvrs0 <- search_tweets("COVID19TX OR coronavirustexas OR coronavirustx", geocode = lookup_coords("USA"), n=5000)

# Setting language: English (en) , Chinese (zh), Korean (ko), Spanish (es)
cvrs_en <- search_tweets("coronavirus,lang:en",geocode = lookup_coords("usa"), n=10000)
cvrs_ko <- search_tweets("coronavirus,lang:ko",geocode = lookup_coords("usa"), n=10000)
cvrs_ch <- search_tweets("coronavirus,lang:zh",geocode = lookup_coords("usa"), n=10000)
cvrs_US <- search_tweets("coronavirus,lang:en",geocode = lookup_coords("usa"), n=10000, retryonratelimit = TRUE)

# Use geocode to locate tweets
cvrs_dallas <- search_tweets("COVID19,lang:en",geocode = "32.8,-96.8,20mi", n=1000)

dallas=lookup_coords("Dallas, TX", "country:US")
cvrs_dallas <- search_tweets("coronavirus,lang:en",geocode = dallas, n=1000)

cvrs_london <- search_tweets("coronavirus,lang:en",geocode = lookup_coords("London"), n=1000)

# Needs Google API key for geocode 
# Visit https://cloud.google.com/maps-platform/ for API key
geocode("Dallas")

# Create lat/lng variables using all available tweet and profile geo-location data
# Note: not all tweets have geo-location data
cvrs0 <- lat_lng(cvrs0)  
cvrs_dallas <- lat_lng(cvrs_dallas)
cvrs_US2 <- lat_lng(cvrs_US2) 


## plot tweet locations onto state map
# set boundaries for state map
## Map data on US map
par(mar = c(0, 0, 0, 0))
maps::map("state", lwd = .4)
with(cvrs_US2, points(lng, lat, pch = 20, cex = .60, col ="red"))

## Map data on Texas map
par(mar = c(0, 0, 0, 0))
maps::map("state", lwd = .4)
states <- map_data("state")
tx_df <- subset(states, region == "texas")

counties <- map_data("county")
tx_county <- subset(counties, region == "texas")
head(tx_county)

tx_base <- ggplot(data = tx_df, mapping = aes(x = long, y = lat)) + 
  coord_fixed(1.2) + 
  geom_polygon(color = "black", fill = "white")

tx_base + theme_bw() + 
  geom_point(data = cvrs_dallas, mapping = aes(x = lng, y = lat), color = "red",lwd = .4)

# Sentiment analysis using TextBlob
pacman::p_load(remotes,reticulate)

# Install from github (development source)
remotes::install_github("news-r/textblob")
library(textblob)

# Download corpora
textblob::download_corpora() 
TG=text_blob("President Trump is nice guy.")
TG$sentiment

pacman::p_load(igraph, ggraph, hrbrthemes, tidygraph, chron, tm, SnowballC, wordCloud, RColorBrewer)
# Graphing retweet connection

ag <- aggregate(cvrs_US2$created_at, "%H", mean)
head(cvrs_US2$created_at)
hr <- as.D(cvrs_US2$created_at, "%H")

# Notes about managing time in classes "POSIXlt" and "POSIXct"
# Use the chron and strptime function(base)

# Convert between Julian and Gregorian
julian(cvrs_US2$created_at)
unlist(month.day.year(17960.28))

# Extracting Day of year
doy <- strftime(cvrs_US2$created_at, format = "%j")
# Extracting Hour
cvrs_US2$hod <- strftime(cvrs_US2$created_at, format = "%H")
# Extracting minute
cvrs_US2$moh <- strftime(cvrs_US2$created_at, format = "%M")
# Extracting time HH:MM:SS
time=strftime(cvrs_US2$created_at, format = "%T")
utctime=strftime(cvrs_US2$created_at, format = "%Z")

head(moh)
head(cvrs_US2$created_at)

# same as previous recipe
filter(cvrs_US2, retweet_count > 0 ) %>% 
  select(screen_name, mentions_screen_name) %>%
  unnest(mentions_screen_name) %>% 
  filter(!is.na(mentions_screen_name)) %>% 
  graph_from_data_frame() -> ct_g
V(ct_g)$node_label <- unname(ifelse(degree(ct_g)[V(ct_g)] > 20, names(V(ct_g)), "")) 
V(ct_g)$node_size <- unname(ifelse(degree(ct_g)[V(ct_g)] > 20, degree(ct_g), 0)) 
ggraph(ct_g, layout = 'kk') + 
  geom_edge_arc(edge_width=0.1, aes(alpha=..index..)) +
  geom_node_label(aes(label=node_label, size=node_size),
                  label.size=0, fill="#ffffff66", segment.colour="light blue",
                  color="red", repel=TRUE, family="Apple Garamond") +
  coord_fixed() +
  scale_size_area(trans="sqrt") +
  labs(title="Retweet Relationships: Coronavirus interactions", subtitle="Edges=volume of retweets. Screenname size=influence") +
  theme_graph(base_family="Apple Garamond") +
  theme(legend.position="none") 
ggraph(ct_g, layout = 'linear', circular= TRUE) + 
  geom_edge_arc(edge_width=0.1, aes(alpha=..index..)) +
  geom_node_label(aes(label=node_label, size=node_size),
                  label.size=0, fill="#ffffff66", segment.colour="light blue",
                  color="red", repel=TRUE, family="Apple Garamond") +
  coord_fixed() +
  scale_size_area(trans="sqrt") +
  labs(title="Retweet Relationships: Coronavirus Tweet interactions", subtitle="Edges=volume of retweets. Screenname size=influence") +
  theme_graph(base_family="Apple Garamond") +
  theme(legend.position="none") 


ggraph(ct_g, layout = 'linear') + 
  geom_edge_arc(edge_width=0.1, aes(alpha=..index..)) +
  geom_node_label(aes(label=node_label, size=node_size),
                  label.size=0, fill="#ffffff66", segment.colour="light blue",
                  color="red", repel=TRUE, family="Apple Garamond") +
  coord_fixed() +
  scale_size_area(trans="sqrt") +
  labs(title="Retweet Relationships: Coronavirus Tweet interactions", subtitle="Edges=volume of retweets. Screenname size=influence") +
  theme_graph(base_family="Apple Garamond") +
  theme(legend.position="none") 

ggraph(ct_g, 'circlepack', weight = 'size') + 
  geom_edge_link() + 
  geom_node_point(aes(colour = depth)) +
  coord_fixed()






graph <- graph_from_data_frame(ct_g)
class(ct_g)

preload("tweenr")
igraph_layouts <- c('star', 'circle', 'gem', 'dh', 'graphopt', 'grid', 'mds', 
                    'randomly', 'fr', 'kk', 'drl', 'lgl')
igraph_layouts <- sample(igraph_layouts)
layouts <- lapply(igraph_layouts, create_layout, graph = ct_g)
V(ct_g)$degree <- degree(ct_g)

layouts_tween <- tween_states(c(layouts, layouts[1]), tweenlength = 1, 
                              statelength = 1, ease = 'cubic-in-out', 
                              nframes = length(igraph_layouts) * 16 + 8)

facet_wrap(~cvrs_US2$hod) + 
  
ggsave(retweet.svg)


ggraph(graph, 'dendrogram') + 
  geom_edge_diagonal() + 
  transition_time(cvrs_US2$created_at) +
  ease_aes('linear')


write.table(cvrs_US2, "cvrs_US2.txt", sep="\t") 
write.csv(cvrs_US2, file="cvrs_US2.csv")
fwrite(cvrs_US2, file ="cvrs_US2.csv")

install.packages("tidytext")
library(tidytext)
data_frame(txt=str_replace_all(cvrs_US$text, "#coronavirus", "")) %>% 
  unnest_tokens(word, txt) %>% 
  anti_join(stop_words, "word") %>% 
  anti_join(rtweet::stopwordslangs, "word") %>% 
  anti_join(data_frame(word=c("https", "t.co")), "word") %>% # need to make a more technical stopwords list or clean up the text better
  filter(nchar(word)>3) %>% 
  pull(word) %>% 
  paste0(collapse=" ") -> txt

# Preparing for word cloud

# Convert the text to lower case
docs <- tm_map(txt, content_transformer(tolower))
# Remove numbers
docs <- tm_map(txt, removeNumbers)
# Remove english common stopwords
docs <- tm_map(txt, removeWords, stopwords("english"))
# Remove your own stop word
# specify your stopwords as a character vector
# docs <- tm_map(txt, removeWords, c("blabla1", "blabla2")) 
# Remove punctuations
docs <- tm_map(txt, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(txt, stripWhitespace)
# Text stemming
# docs <- tm_map(docs, stemDocument)

dtm <- TermDocumentMatrix(txt)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
set.seed(1234)
wordcloud(words = txt, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

cloud_img <- word_cloud(txt, width=800, height=500,  min_font_size=10, max_font_size=60, scale="log")

