from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pickle
import numpy as np
import pandas as pd
import os

app = FastAPI()

# Load models and scaler
MODELS_PATH = 'assets/models/saved_models/'
scaler = pickle.load(open(os.path.join(MODELS_PATH, 'scaler.pkl'), 'rb'))

models = {
    'rf': pickle.load(open(os.path.join(MODELS_PATH, 'random_forest_tuned.pkl'), 'rb')),
    'svm': pickle.load(open(os.path.join(MODELS_PATH, 'svm_tuned.pkl'), 'rb')),
    'knn': pickle.load(open(os.path.join(MODELS_PATH, 'knn_tuned.pkl'), 'rb')),
}

class CustomerData(BaseModel):
    credit_score: int
    age: int
    tenure: int
    balance: float
    num_products: int
    has_card: bool
    is_active: bool
    salary: float
    geography: str
    gender: str
    model_type: str = 'rf'

@app.post("/predict")
async def predict(data: CustomerData):
    if data.model_type not in models:
        raise HTTPException(status_code=400, detail="Invalid model type")

    # Preprocessing (Mirroring the training pipeline)
    # Features: ['CreditScore', 'Age', 'Tenure', 'Balance', 'NumOfProducts', 'HasCrCard', 'IsActiveMember', 'EstimatedSalary', 'Geography_Germany', 'Geography_Spain', 'Gender_Male']
    
    features = [
        data.credit_score,
        data.age,
        data.tenure,
        data.balance,
        data.num_products,
        1 if data.has_card else 0,
        1 if data.is_active else 0,
        data.salary,
        1 if data.geography == 'Germany' else 0,
        1 if data.geography == 'Spain' else 0,
        1 if data.gender == 'Male' else 0,
    ]
    
    # Scale
    features_scaled = scaler.transform([features])
    
    # Predict
    model = models[data.model_type]
    
    # Some models have predict_proba, some just predict
    if hasattr(model, "predict_proba"):
        probability = model.predict_proba(features_scaled)[0][1]
    else:
        # For SVM or others that might not have proba enabled
        probability = float(model.predict(features_scaled)[0])
        
    return {"probability": float(probability), "model_used": data.model_type}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
