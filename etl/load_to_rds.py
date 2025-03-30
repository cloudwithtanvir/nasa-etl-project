import os
from sqlalchemy import create_engine
from transform import clean_apod

DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

def load_to_rds(df, table_name):
    engine = create_engine(f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}")
    df.to_sql(table_name, engine, if_exists='replace', index=False)

if __name__ == "__main__":
    df = clean_apod("apod_raw.json")
    load_to_rds(df, "apod")
