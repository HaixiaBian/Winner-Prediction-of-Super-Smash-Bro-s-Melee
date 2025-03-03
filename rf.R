library(ranger)
library(tuneRanger)
library(vip)
# library(ROCR)



# Data
train = read.csv("train.csv")
train = within(train, rm(frame, game_id, tourn_id))
train = na.omit(train)

test = read.csv("test.csv")
test = within(test, rm(frame, game_id, tourn_id))
test = na.omit(test)



# randomForest
# rf = ranger(formula = winner ~ ., data = train)
# rf = ranger(formula = winner ~ .,
#             data = train,
#             probability = TRUE)
rf = ranger(formula = winner ~ .,
            data = train,
            probability = TRUE,
            importance = "impurity")


# Test
predictTest = predict(rf, data = test)$predictions

# table(test$winner, predictTest)
# (37073 + 37346) / 104048

ROCRpred = prediction(predictTest[, 2], test$winner)
ROCRperf = performance(ROCRpred, "tpr", "fpr")
plot(
  ROCRperf,
  colorize = TRUE,
  print.cutoffs.at = 0.5,
  text.adj = c(-0.5, 0.5)
)
table(test$winner, predictTest[, 2] >= 0.5)
(37071 + 37213) / 104048

# Tune
melee = makeClassifTask(data = train, target = "winner")
estimateTimeTuneRanger(melee)
rf_acc = tuneRanger(melee, measure = list(acc))
rf_auc = tuneRanger(melee, measure = list(auc))

# Plot
vip(rf) + ggtitle("Random Forest Feature Importance")