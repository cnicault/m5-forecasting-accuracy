library(tidyverse)

calendar <- read_csv(here::here("data", "calendar.csv"))

ca1 <- read_csv(here::here("output", "evaluation", "M5_store_valid_CA_1.csv"))
ca2 <- read_csv(here::here("output", "evaluation", "M5_store_valid_CA_2.csv"))
ca3 <- read_csv(here::here("output", "evaluation", "M5_store_valid_CA_3.csv"))
ca4 <- read_csv(here::here("output", "evaluation", "M5_store_valid_CA_4.csv"))
tx1 <- read_csv(here::here("output", "evaluation", "M5_store_valid_TX_1.csv"))
tx2 <- read_csv(here::here("output", "evaluation", "M5_store_valid_TX_2.csv"))
tx3 <- read_csv(here::here("output", "evaluation", "M5_store_valid_TX_3.csv"))
wi1 <- read_csv(here::here("output", "evaluation", "M5_store_valid_WI_1.csv"))
wi2 <- read_csv(here::here("output", "evaluation", "M5_store_valid_WI_2.csv"))
wi3 <- read_csv(here::here("output", "evaluation", "M5_store_valid_WI_3.csv"))


sample_submission <- read_csv(here::here("data", "sample_submission.csv"))
submission_names <- colnames(sample_submission)

predictions <- ca1 %>%
  bind_rows(ca2) %>%
  bind_rows(ca3) %>%
  bind_rows(ca4) %>%
  bind_rows(tx1) %>%
  bind_rows(tx2) %>%
  bind_rows(tx3) %>%
  bind_rows(wi1) %>%
  bind_rows(wi2) %>%
  bind_rows(wi3)

header <- colnames(predictions)

# Create the submission file with predictions
submit_preds <- sample_submission %>%
  select(id) %>%
  left_join(predictions) %>%
  rename_all(~submission_names)

# Replace all NAs corresponding to the evaluation file
submit_preds <- submit_preds %>%
  filter(str_detect(id, "evaluation"))

# Create the output file
write_csv(submit_preds, here::here("output", "evaluation", "M5_evaluation.csv"))

