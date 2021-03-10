library(tidyverse)
library(plotly)
calendar <- read_csv(here::here("data", "calendar.csv"))

valid <- read_csv(here::here("output", "validation", "M5_validation.csv"))
eval <- read_csv(here::here("output", "evaluation", "M5_evaluation.csv"))



sample_submission <- read_csv(here::here("data", "sample_submission.csv"))
submission_names <- colnames(sample_submission)


predictions <- valid %>%
  bind_rows(eval)

header <- colnames(predictions)
# predictions <- predictions %>%
#   mutate_if(is.numeric, ~(.*1.01))

# Create the submission file with predictions
submit_preds <- sample_submission %>%
  select(id) %>%
  left_join(predictions)

write_csv(submit_preds, here::here("output", "final", "M5_predictions_final.csv"))
