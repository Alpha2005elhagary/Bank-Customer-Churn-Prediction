from flask import Flask, request, render_template
import joblib
import pandas as pd
import numpy as np

app = Flask(__name__)

# Load models and preprocessors
print("📂 Loading models...")
rf_model = joblib.load('saved_models/random_forest_model.pkl')
dt_model = joblib.load('saved_models/decision_tree_model.pkl')
svm_model = joblib.load('saved_models/svm_model.pkl')
knn_model = joblib.load('saved_models/knn_model.pkl')
scaler = joblib.load('saved_models/scaler.pkl')
label_encoders = joblib.load('saved_models/label_encoders.pkl')
print("✅ All models loaded successfully!")

# Check scaler features
print(f"\n📊 Scaler expects {scaler.n_features_in_} features")
if hasattr(scaler, 'feature_names_in_'):
    print(f"   Scaler features: {scaler.feature_names_in_}")
else:
    print("   Scaler has no feature names (was trained on array)")

# Model expects these exact columns in this order
MODEL_FEATURES = ['CreditScore', 'Geography', 'Gender', 'Age', 'Tenure', 
                  'Balance', 'NumOfProducts', 'HasCrCard', 'IsActiveMember', 'EstimatedSalary']

# Numerical features that were scaled (based on your original preprocessing)
NUMERICAL_FEATURES = ['CreditScore', 'Age', 'Tenure', 'Balance', 'NumOfProducts', 'EstimatedSalary']

models_dict = {
    'Random Forest': rf_model,
    'Decision Tree': dt_model,
    'SVM': svm_model,
    'KNN': knn_model
}

@app.route('/')
def home():
    return render_template('index.html', form_data={}, result=None, all_results=None, error=None)

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get form data
        credit_score = float(request.form['credit_score'])
        geography = request.form['geography']
        gender = request.form['gender']
        age = float(request.form['age'])
        tenure = float(request.form['tenure'])
        balance = float(request.form['balance'])
        num_products = float(request.form['num_products'])
        has_cr_card = float(request.form['has_cr_card'])
        is_active = float(request.form['is_active'])
        estimated_salary = float(request.form['estimated_salary'])
        selected_model = request.form['model']
        
        # Create full dataframe with all features
        customer_df = pd.DataFrame([{
            'CreditScore': credit_score,
            'Geography': geography,
            'Gender': gender,
            'Age': age,
            'Tenure': tenure,
            'Balance': balance,
            'NumOfProducts': num_products,
            'HasCrCard': has_cr_card,
            'IsActiveMember': is_active,
            'EstimatedSalary': estimated_salary
        }])
        
        # Encode categorical variables
        customer_df['Geography'] = label_encoders['Geography'].transform(customer_df['Geography'])
        customer_df['Gender'] = label_encoders['Gender'].transform(customer_df['Gender'])
        
        # Scale ONLY numerical features (same as training)
        customer_df[NUMERICAL_FEATURES] = scaler.transform(customer_df[NUMERICAL_FEATURES])
        
        # Ensure correct column order
        customer_df = customer_df[MODEL_FEATURES]
        
        # Make prediction
        model = models_dict[selected_model]
        prediction = model.predict(customer_df)[0]
        probability = model.predict_proba(customer_df)[0][1]
        
        result = {
            'model_used': selected_model,
            'prediction': '⚠️ WILL CHURN' if prediction == 1 else '✅ WILL STAY',
            'churn_probability': f"{probability:.2%}",
            'risk_level': '🔴 HIGH RISK' if probability > 0.7 else '🟡 MEDIUM RISK' if probability > 0.3 else '🟢 LOW RISK',
            'recommendation': get_recommendation(probability)
        }
        
        return render_template('index.html', result=result, form_data=request.form, all_results=None, error=None)
    
    except Exception as e:
        import traceback
        error_detail = traceback.format_exc()
        print(error_detail)
        return render_template('index.html', error=f"Error: {str(e)}", form_data=request.form, result=None, all_results=None)

@app.route('/predict_all', methods=['POST'])
def predict_all():
    try:
        # Get form data
        credit_score = float(request.form['credit_score'])
        geography = request.form['geography']
        gender = request.form['gender']
        age = float(request.form['age'])
        tenure = float(request.form['tenure'])
        balance = float(request.form['balance'])
        num_products = float(request.form['num_products'])
        has_cr_card = float(request.form['has_cr_card'])
        is_active = float(request.form['is_active'])
        estimated_salary = float(request.form['estimated_salary'])
        
        # Create full dataframe with all features
        customer_df = pd.DataFrame([{
            'CreditScore': credit_score,
            'Geography': geography,
            'Gender': gender,
            'Age': age,
            'Tenure': tenure,
            'Balance': balance,
            'NumOfProducts': num_products,
            'HasCrCard': has_cr_card,
            'IsActiveMember': is_active,
            'EstimatedSalary': estimated_salary
        }])
        
        # Encode categorical variables
        customer_df['Geography'] = label_encoders['Geography'].transform(customer_df['Geography'])
        customer_df['Gender'] = label_encoders['Gender'].transform(customer_df['Gender'])
        
        # Scale ONLY numerical features (same as training)
        customer_df[NUMERICAL_FEATURES] = scaler.transform(customer_df[NUMERICAL_FEATURES])
        
        # Ensure correct column order
        customer_df = customer_df[MODEL_FEATURES]
        
        # Predict with all models
        all_results = []
        for name, model in models_dict.items():
            prediction = model.predict(customer_df)[0]
            probability = model.predict_proba(customer_df)[0][1]
            all_results.append({
                'model': name,
                'prediction': '⚠️ WILL CHURN' if prediction == 1 else '✅ WILL STAY',
                'probability': f"{probability:.2%}",
                'risk': '🔴 HIGH' if probability > 0.7 else '🟡 MEDIUM' if probability > 0.3 else '🟢 LOW'
            })
        
        return render_template('index.html', all_results=all_results, form_data=request.form, result=None, error=None)
    
    except Exception as e:
        import traceback
        error_detail = traceback.format_exc()
        print(error_detail)
        return render_template('index.html', error=f"Error: {str(e)}", form_data=request.form, result=None, all_results=None)

def get_recommendation(probability):
    if probability > 0.7:
        return "🚨 Immediate action needed! Offer special discounts and call customer immediately."
    elif probability > 0.3:
        return "📞 Monitor this customer closely. Send personalized offers and loyalty rewards."
    else:
        return "👍 Customer is loyal and satisfied. Continue providing excellent service."

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)