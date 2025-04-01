import pandas as pd, json

def clean_apod(file_path):
    with open(file_path) as f:
        data = json.load(f)
    df = pd.DataFrame(data)
    df["date"] = pd.to_datetime(df["date"])
    df = df.drop_duplicates()
    return df
