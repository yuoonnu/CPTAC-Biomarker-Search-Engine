if (!require("tidytext", quietly = TRUE)) install.packages("tidytext")
if (!require("dplyr", quietly = TRUE)) install.packages("dplyr")

library(dplyr)
library(tidytext)

desc_data <- read.csv("protein_description.csv", stringsAsFactors = FALSE)

# 1. Calculate Term Frequency (TF)
desc_words <- desc_data %>%
  unnest_tokens(word, GO_Terms_Text) %>% 
  count(SYMBOL, word, sort = TRUE)

total_words <- desc_words %>%
  group_by(SYMBOL) %>%
  summarize(total = sum(n))

desc_words <- left_join(desc_words, total_words)

# 2. Draw Histogram of Term Frequency (Targeting 4 specific symbols for sample)
if(!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")

library(ggplot2)

target_symbols <- c("TGFB1", "NOTCH1", "CTNNB1", "AKT1")
subset_words <- desc_words %>% 
  filter(SYMBOL %in% target_symbols)

ggplot(subset_words, aes(n/total, fill = SYMBOL)) +
  geom_histogram(show.legend = FALSE, bins = 30) +
  facet_wrap(~SYMBOL, ncol = 2, scales = "free_y")

# 3. Calculate rank and term frequency for Zipf's law
freq_by_rank <- desc_words %>% 
  filter(SYMBOL %in% target_symbols) %>%
  group_by(SYMBOL) %>% 
  mutate(rank = row_number(), 
         term_frequency = n/total) %>%
  ungroup()

# 4. Linear Modeling for Zipf's Law (Subset range 10 ~ 500)
rank_subset <- freq_by_rank %>% 
  filter(rank < 500,
         rank > 10)
lm(log10(term_frequency) ~ log10(rank), data = rank_subset)

# 5.Plotting Zipf's Law with regression line
freq_by_rank %>% 
  ggplot(aes(rank, term_frequency, color = SYMBOL)) + 
  geom_abline(intercept = -0.62, slope = -1.1, 
              color = "gray50", linetype = 2) +
  geom_line(linewidth = 1.1, alpha = 0.8, show.legend = FALSE) + 
  scale_x_log10() +
  scale_y_log10()

# 6. Calculate TF-IDF scores
desc_tf_idf <- desc_words %>%
  bind_tf_idf(word, SYMBOL, n)

# 7.Visualize Top 15 TF-IDF Keywords (With Stop-words Removal)
if (!require("forcats", quietly = TRUE)) install.packages("forcats")
library(forcats)

desc_tf_idf %>%
  filter(SYMBOL %in% target_symbols) %>%
  anti_join(stop_words, by = "word") %>%
  group_by(SYMBOL) %>%
  slice_max(tf_idf, n = 15) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, tf_idf, SYMBOL)) %>%
  ggplot(aes(tf_idf, fct_reorder(word, tf_idf), fill = SYMBOL)) +
  geom_col(show.legend = FALSE) +
  scale_y_reordered() +
  facet_wrap(~SYMBOL, ncol = 2, scales = "free") +
  labs(x = "tf-idf", y = NULL)

# 8. Extract Top 5 purely biological keywords per protein
top_keywords_full <- desc_tf_idf %>%
  anti_join(stop_words, by = "word") %>%
  group_by(SYMBOL) %>%
  slice_max(tf_idf, n = 5, with_ties = FALSE) %>% 
  summarise(Top_Keywords = paste(word, collapse = ", ")) %>% 
  ungroup()

# 9. Merge keywords into original metadata and limit string length
final_search_index <- desc_data %>%
  left_join(top_keywords_full, by = "SYMBOL") %>%
  mutate(Top_Keywords = ifelse(is.na(Top_Keywords), "None", Top_Keywords),
         GO_Terms_Text = substr(GO_Terms_Text, 1, 3900))

# 10. Export the final clean dataset
write.csv(final_search_index, "protein_search_index_full.csv", row.names = FALSE)