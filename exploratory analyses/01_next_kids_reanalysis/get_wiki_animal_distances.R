# get distances between animals based on wikipedia

library(tidyverse)
library(here)
library(data.table)

LABELS_PATH <- here("data/next_kids_pilot/labels.txt")
MODEL_PATH <- "/Users/mollylewis/Documents/research/Projects/1_in_progress/VOCAB_SEEDS/exploratory_analyses/0_exploration/wiki.en.vec"
OUTPATH <- here("data/next_kids_pilot/next_animal_distances.csv")

labs <- read.table(LABELS_PATH, header = FALSE) %>%
  rename(item = V1) %>%
  mutate(item = lapply(str_split(item, ".jpg"),
                       function(x) {x[1]})) %>%
  pull(item) %>%
  unlist()

wmodel <- fread(
  MODEL_PATH,
  header = FALSE,
  skip = 1,
  quote = "",
  encoding = "UTF-8",
  data.table = TRUE,
  col.names = c("target_word",
                unlist(lapply(2:301, function(x) paste0("V", x)))))

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
