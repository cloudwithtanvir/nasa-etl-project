import os
import json
import boto3
import requests
import pandas as pd
from datetime import datetime, timedelta
from sqlalchemy import create_engine

# --- Retrieve a secret from AWS Secrets Manager ---
def get_secret(secret_arn):
    client = boto3.client("secretsmanager")
    try:
        response = client.get_secret_value(SecretId=secret_arn)
        return json.loads(response["SecretString"])
    except Exception as e:
        raise Exception(f"Error retrieving secret {secret_arn}: {e}")

# --- Load secrets from lowercase env vars (Glue passes them as-is) ---
NASA_SECRET_ARN = os.environ.get("nasa_secret_arn")
DB_SECRET_ARN = os.environ.get("secret_arn")  # for database credentials

if not NASA_SECRET_ARN:
    raise Exception("nasa_secret_arn environment variable is missing.")
if not DB_SECRET_ARN:
    raise Exception("secret_arn (DB) environment variable is missing.")

# --- Fetch secrets ---
nasa_secret = get_secret(NASA_SECRET_ARN)
db_secret = get_secret(DB_SECRET_ARN)

NASA_API_KEY = nasa_secret.get("NASA_API_KEY")
DB_USER = db_secret.get("DB_USER")
DB_PASS = db_secret.get("DB_PASS")
DB_HOST = db_secret.get("DB_HOST")
DB_NAME = db_secret.get("DB_NAME")

# --- Extract APOD data day-by-day ---
def fetch_apod_daily(start_date, end_date):
    all_data = []
    current = start_date
    max_date = datetime.utcnow() - timedelta(days=1)

    while current <= end_date and current <= max_date:
        url = "https://api.nasa.gov/planetary/apod"
        params = {
            "api_key": NASA_API_KEY,
            "date": current.strftime('%Y-%m-%d')
        }
        try:
            response = requests.get(url, params=params)
            response.raise_for_status()
            all_data.append(response.json())
            print(f"{current.strftime('%Y-%m-%d')} fetched")
        except Exception as e:
            print(f"Skipping {current.strftime('%Y-%m-%d')}: {e}")
        current += timedelta(days=1)

    return all_data

# --- Clean and normalize the data ---
def clean_apod(data):
    if not data:
        raise Exception("No APOD data fetched.")
    df = pd.DataFrame(data)
    df = df[["date", "title", "explanation", "url", "media_type"]]
    df["date"] = pd.to_datetime(df["date"])
    df = df.drop_duplicates()
    return df

# --- Load into PostgreSQL RDS ---
def load_to_rds(df):
    db_url = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"
    engine = create_engine(db_url)
    df.to_sql("apod", engine, if_exists="replace", index=False)
    print("Data loaded into RDS successfully.")

# --- Main ETL logic ---
def main():
    end = datetime.utcnow() - timedelta(days=2)
    start = end - timedelta(days=29)

    print(f"Fetching APOD data from {start.date()} to {end.date()}...")

    try:
        raw_data = fetch_apod_daily(start, end)
        print(f"Collected {len(raw_data)} entries")

        cleaned_df = clean_apod(raw_data)
        print("Data cleaned and transformed")

        load_to_rds(cleaned_df)

    except Exception as e:
        print(f"ETL job failed: {e}")

if __name__ == "__main__":
    main()
