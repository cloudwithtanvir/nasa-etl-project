import requests
import os
import json
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Load NASA API key from .env
load_dotenv()
NASA_API_KEY = os.getenv("NASA_API_KEY")
ENDPOINT = "https://api.nasa.gov/planetary/apod"

def fetch_apod(start_date, end_date):
    params = {
        "api_key": NASA_API_KEY,
        "start_date": start_date,
        "end_date": end_date
    }
    response = requests.get(ENDPOINT, params=params)
    response.raise_for_status()
    return response.json()

if __name__ == "__main__":
    # Set date range to past 30 days, avoiding today
    end = datetime.now() - timedelta(days=1)
    start = end - timedelta(days=29)
    try:
        data = fetch_apod(start.strftime('%Y-%m-%d'), end.strftime('%Y-%m-%d'))
        with open("apod_raw.json", "w") as f:
            json.dump(data, f, indent=2)
        print("Data saved to apod_raw.json")
    except requests.exceptions.HTTPError as e:
        print(f"API Error: {e}")
    except Exception as e:
        print(f"Unexpected Error: {e}")
