IL <- read_excel("IL.xlsx")

# Linear model for Income,Population, and Per SqFt Price, and 
# combination of the variables

model1 = lm(IL$House_Price~IL$Income)
model2 = lm(IL$House_Price~IL$Income+IL$Population)
model3 = lm(IL$House_Price~IL$Income+IL$Population+
              IL$Per_SqFt_Price)

# Summary and details of the models
summary(model1)
summary(model2)
summary(model3)
