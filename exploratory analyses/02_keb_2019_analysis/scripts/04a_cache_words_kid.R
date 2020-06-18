library(tidyverse)
library(data.table)
library(here)

OUTPATH <- here("data/keb_reanalysis/cached_vectors_kid.csv")
TARGET_WORDS <- here("data/keb_reanalysis/words_to_cache.csv")
MODEL_PATH <- here("data/trained_sampled_kidbook/trained_sampled_kidbook_5_count_1.csv")

target_words <- read_csv(TARGET_WORDS) %>%
  distinct(word) %>%
  pull(word)

wmodel <- read_csv(MODEL_PATH) %>%
  rename(target_word = word)


target_vecs <- wmodel %>%
  filter(target_word %in% target_words) %>%
  select(target_word, everything())


write_csv(target_vecs, OUTPATH)
