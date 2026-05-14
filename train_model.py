import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
import json

# Load the dataset
df = pd.read_csv('Churn_Modelling.csv')

# Preprocessing
# Drop unnecessary columns
X = df.drop(['RowNumber', 'CustomerId', 'Surname', 'Exited'], axis=1)
y = df['Exited']

# Convert categorical data
X = pd.get_dummies(X, columns=['Geography', 'Gender'], drop_first=True)

# Split the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Scale the data
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# Train a simpler model that is easy to export (Logistic Regression coefficients are easy)
# But user asked for "Python model", let's use a small Random Forest and export its logic if possible
# Or just export a simple Linear model weights for now to demonstrate the "Deployment"
from sklearn.linear_model import LogisticRegression
model = LogisticRegression()
model.fit(X_train_scaled, y_train)

# Export Model Parameters
model_params = {
    'coefficients': model.coef_[0].tolist(),
    'intercept': model.intercept_[0],
    'mean': scaler.mean_.tolist(),
    'scale': scaler.scale_.tolist(),
    'columns': X.columns.tolist()
}

with open('assets/models/churn_model_params.json', 'w') as f:
    json.dump(model_params, f)

print("Model trained and parameters exported to assets/models/churn_model_params.json")
