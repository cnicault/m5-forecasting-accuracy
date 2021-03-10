library(data.table)
library(tidyverse)
library(lubridate)
library(tictoc)
library(here)

sales <- fread(here::here("data", "sales_train_evaluation.csv"))
cal <- fread(here::here("data", "calendar.csv"))
prices <- fread(here::here("data", "sell_prices.csv"))

h <- 28 
tr_last <- 1913
# by state / store
tic()

index <- sales[,1:6]

sales[, paste0("d_", (tr_last+1):(tr_last+2*h)) := NA_real_]

sales <- melt(sales,
              measure.vars = patterns("^d_"),
              variable.name = "d",
              value.name = "value")[order(id)]


sales <- sales[cal, `:=`(wm_yr_wk = i.wm_yr_wk, date = i.date), on = "d"]

sales[prices, `:=`(sell_price = i.sell_price), on = c("store_id", "item_id", "wm_yr_wk")]

sales <- sales[!is.na(sell_price)]

full_item_id <- sales[, .(item_avg = mean(value, na.rm = TRUE),
                          item_sd = sd(value, na.rm = TRUE)), by = .(item_id)]

full_dept_id <- sales[, .(dept_avg = mean(value, na.rm = TRUE),
                          dept_sd = sd(value, na.rm = TRUE)), by = .(dept_id)]

full_store_id <- sales[, .(store_avg = mean(value, na.rm = TRUE),
                           store_sd = sd(value, na.rm = TRUE)), by = .(store_id)]

full_cat_id <- sales[, .(cat_avg = mean(value, na.rm = TRUE),
                         cat_sd = sd(value, na.rm = TRUE)), by = .(cat_id)]

full_state_item <- sales[, .(state_item_avg = mean(value, na.rm = TRUE),
                             state_item_sd = sd(value, na.rm = TRUE)), by = .(state_id, item_id)]

full_state_dept <- sales[, .(state_dept_avg = mean(value, na.rm = TRUE),
                             state_dept_sd = sd(value, na.rm = TRUE)), by = .(state_id, dept_id)]

full_state_cat <- sales[, .(state_cat_avg = mean(value, na.rm = TRUE),
                            state_cat_sd = sd(value, na.rm = TRUE)), by = .(state_id, cat_id)]

full_store_dept <- sales[, .(store_dept_avg = mean(value, na.rm = TRUE),
                             store_dept_sd = sd(value, na.rm = TRUE)), by = .(store_id, dept_id)]

sales[, c("dept_id", "cat_id", "state_id", "wm_yr_wk", "value"):=NULL]

sales[, `:=`(year = lubridate::year(ymd(date)), month = lubridate::month(ymd(date)))]

price_mom_m <- sales[,.(item_id, store_id, d, month, sell_price)
                     ][,`:=`(price_month = mean(sell_price, na.rm = TRUE)), by = .(item_id, store_id, month)
                       ][,`:=`(price_mom_m = sell_price / price_month)
                         ][,-c("price_month", "sell_price", "month")]
price_mom_y <- sales[,.(item_id, store_id, d, year, sell_price)
                     ][,`:=`(price_year = mean(sell_price, na.rm = TRUE)), by = .(item_id, store_id, year)
                       ][,`:=`(price_mom_y = sell_price / price_year)
                         ][,-c("price_year", "sell_price", "year")]

rm(sales); gc()

prices_change <- prices %>%
  arrange(store_id, item_id, wm_yr_wk) %>%
  mutate(change = c(NA, diff(sell_price)))

setDT(prices_change)
prices_change[index, `:=`(dept_id = i.dept_id, cat_id = i.cat_id, state_id = i.state_id), on = c("store_id", "item_id")]
# sales[prices, `:=`(sell_price = i.sell_price), on = c("store_id", "item_id", "wm_yr_wk")]
prices_change <- prices_change %>%
  filter(change !=0)%>%
  group_by(item_id, wm_yr_wk) %>%
  mutate(nb_stores = length(store_id),
         nb_states = length(unique(state_id)),
         rapp_change_avg = change / mean(change, na.rm = T)) %>%
  ungroup() %>%
  select(item_id, wm_yr_wk, store_id, nb_stores, nb_states, rapp_change_avg)
setDT(prices_change)


toc()

save(full_item_id, full_dept_id, full_cat_id, full_state_item, full_state_dept, full_state_cat, full_store_id, full_store_dept, price_mom_m, price_mom_y, prices_change, file = here::here("wrk", "extra_data_eval.RData"))
