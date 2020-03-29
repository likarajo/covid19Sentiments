# Task    : Sentiment Analysis of Corona Virus Tweets
# Dataset : Fetched using GetOldTweets3

# Install required packages
install.packages("tidytext")
library(tidytext)
install.packages("data.table", repos = "https://cran.r-project.org")
library(data.table)
if (!"dplyr" %in% installed.packages()[, "Package"]){
  install.packages("dplyr",dependencies=T)
}
library(dplyr)
install.packages("ggplot2")
library(ggplot2)
install.packages("textdata")
library(textdata)
install.packages("wordcloud")
library(wordcloud)
install.packages("reshape2", repos = "https://cran.r-project.org")
library(reshape2)

# 1. Read data file
covid19 = fread("data/corona_0320_0328.csv", 
                strip.white=T, sep=",", header=T, na.strings=c("", " ", "NA", "nan", "NaN", "nannan"))

str(covid19)
colnames(covid19) # column names
n = nrow(covid19) # number of observations
n

# 1.1. Randomly select 100% of obs.
trainIndex = sample(1:n,size = round(1.0*n),replace=FALSE)
covid19_data = covid19[trainIndex,]

# 2. Tokenize tweet text into words for further pre-processing
tidy_text <- covid19_data %>%
  # 2.1. The function unnest_tokens splits each row such that there is one token (word) in each row of the new data frame
  unnest_tokens(word, text)
tidy_text[1:20]

# 3. Remove the stop words from the data
data(stop_words)
stop_words
tidy_text <- tidy_text %>%
  anti_join(stop_words)

# 4. Remove the keywords from the data
l = c("COVID19", "covid19", "covid_19", "covid", "19", "covid2019", "Coronavirus", "coronavirus", 
      "corona", "Corona", "2019", "2020","http", "https", "coronavirusoutbreak", "coronaviruspandemic",
      "disease", "pandemic", "virus", "trump", "china")
key_words <- data.frame(word=matrix(unlist(l)))
key_words
tidy_text <- tidy_text %>%
  anti_join(key_words)

# 6. Visualization the most commonly used words 
png("common_words.png")
common_words <- tidy_text %>%
  count(word, sort = TRUE) %>%
  filter(n > 20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_bar(stat = "identity") +
  labs(x = "count", title = "Common words") +
  xlab(NULL) +
  coord_flip()
print(common_words)
dev.off()

# 7. Visualizing the words in a word cloud
png("sentiment_words.png")
sentiment_words <- tidy_text %>%
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))
print(sentiment_words)
dev.off()

# 8. Analyzing the positive and negative words using Bing sentiment
png("sentiment_words_class.png")
sentiment_words_class <- tidy_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"), max.words = 100)
print(sentiment_words_class)
dev.off()

                   max.words = 100)