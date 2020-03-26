## Analyzing Coronavirus sentiments in Twitter

# Prepare needed packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tm,tidyverse,data.table)
library(tm)
library(tidyverse)
library(data.table)

# Import data
cortx <- read.csv("data/corona_0325.csv", stringsAsFactors = FALSE)

# Tokenize text
twttextDF <- data_frame(text=cortx$text)
tidytwt= twttextDF %>% 
  unnest_tokens(word, text)

# Call in the stop word dictionary
data(stop_words)

## Adding "trump" as stop word
nws_x=array(c("trump","Trump","https"))
nws_y=rep("custom", each=dim(nws_x))
newsw <- data.frame( "word" = nws_x, "lexicon" = nws_y)
stop_words1 <- rbind(stop_words, newsw) 

## Removing stop words
tidytwt <- tidytwt %>%  anti_join(stop_words1)

## First plot: most used words
tidytwt %>%
  count(word, sort = TRUE) %>%
  filter(n > 200) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() + theme_bw()

tidytwt <- tidytwt %>%
  mutate(linenumber = row_number())

# Sentiment analysis
# On average one tweet has 12 words.
# Plotting spread of sentiments
sentiment_CTT <- tidytwt %>%          
  inner_join(get_sentiments("bing")) %>%
  count(index = linenumber %/% 12, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)
ggplot(sentiment_CTT, aes(index, sentiment)) +
  geom_col(show.legend = FALSE)+theme_bw()

# Plotting the positive and negative words
bing_word_counts %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Corona Virus in Texas",
       x = NULL) +
  coord_flip() + theme_bw()+ theme(strip.text.x = element_text(family="Apple Garamond"), 
                                   axis.title.x=element_text(face="bold", size=15,family="Apple Garamond"),
                                   axis.title.y=element_text(family="Apple Garamond"), 
                                   axis.text.x = element_text(family="Apple Garamond"), 
                                   axis.text.y = element_text(family="Apple Garamond"))

# Save to image file (SVG)
ggsave("CT_2020_sentiments.svg", device=svg, dpi=600)

# Save data before exit
save.image("CT.RData")

