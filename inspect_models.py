import pickle
import json
import numpy as np

# Let's try to inspect the models and see if we can export their logic
models = [
    'ann_model.pkl',
    'random_forest_model.pkl',
    'svm_model.pkl',
    'knn_tuned.pkl'
]

model_info = {}

for model_name in models:
    try:
        with open(f'assets/models/saved_models/{model_name}', 'rb') as f:
            model = pickle.load(f)
            model_info[model_name] = str(type(model))
    except Exception as e:
        model_info[model_name] = f"Error: {e}"

print(json.dumps(model_info, indent=2))
