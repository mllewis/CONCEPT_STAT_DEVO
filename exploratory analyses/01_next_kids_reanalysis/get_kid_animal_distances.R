# get distances between animals based on kid

library(tidyverse)
library(here)
library(data.table)

LABELS_PATH <- here("data/next_kids_pilot/labels.txt")
MODEL_PATH <- here("data/trained_sampled_kidbook/trained_sampled_kidbook_5_count_1.csv")
OUTPATH <- here("data/next_kids_pilot/next_animal_distances_kid.csv")

labs <- read.table(LABELS_PATH, header = FALSE) %>%
  rename(item = V1) %>%
  mutate(item = lapply(str_split(item, ".jpg"),
                       function(x) {x[1]})) %>%
  pull(item) %>%
  unlist()


wmodel <- read_csv(MODEL_PATH) %>%
  rename(target_word = word)

target_vecs <- wmodel %>%
  filter(target_word %in% labs) %>%
  select(target_word, everything())
# missing:  "unmuscular" "semibright"

word_word_dists <- philentropy::distance(as.matrix(target_vecs[,-1]),
                                         method = "cosine") %>%
  as.data.frame()  %>%
  mutate(word1 = target_vecs$target_word)

colnames(word_word_dists) = c( target_vecs$target_word, "item.x")

long_word_word_dists <- gather(word_word_dists, "item.y", "language_similarity", -item.x)

write_csv(long_word_word_dists, OUTPATH)
