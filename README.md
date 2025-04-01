## NASA ETL Pipeline Project

This project implements an end-to-end ETL pipeline that collects data from multiple NASA APIs, processes it, and stores it in an AWS RDS PostgreSQL database using AWS Glue. A separate microservice hosted on AWS Lightsail adds additional image-based insights to enrich the dataset.

---

### Key Features

- Extracts data from:
  - NASA Astronomy Picture of the Day (APOD)
  - Near-Earth Object Web Service (NeoWs)
  - Mars Rover Photos API
- Cleans, normalizes, and merges the data into a unified format
- Loads the processed data into AWS RDS (PostgreSQL)
- Deploys a Flask-based microservice on AWS Lightsail for image analysis
- Automates the entire ETL process using AWS Glue
- Manages secrets securely with AWS Secrets Manager
- Uses Terraform to provision infrastructure

---



### Running Locally

1. **Install Dependencies**

Make sure you have Python 3 installed. Then run:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

2. **Create a `.env` File**

Copy from `.env.example` and fill in your values:

```env
NASA_API_KEY=your_nasa_api_key
DB_USER=your_db_user
DB_PASS=your_db_password
DB_HOST=your_rds_host
DB_NAME=your_database
LIGHTSAIL_API=http://your-lightsail-ip/analyze-image
```

3. **Run the ETL Pipeline**

You can test the full pipeline locally:

```bash
python etl/extract.py
python etl/transform.py
python etl/load_to_rds.py
```

---

### AWS Deployment

**Services Used:**

- AWS Glue: Orchestrates the ETL jobs
- AWS RDS: Stores the cleaned data
- AWS Lightsail: Hosts the enrichment microservice
- AWS Secrets Manager: Securely stores credentials
- AWS S3: Stores ETL scripts for Glue jobs

**Deploy using Terraform:**

```bash
cd terraform
terraform init
terraform apply
```

This will provision your AWS infrastructure, including IAM roles, RDS instance, secrets, S3 buckets, and Glue job setup.

---

### Lightsail Microservice

The microservice runs a Flask API and is accessible via a `/analyze-image` endpoint. It accepts a JSON payload with an image URL and returns basic metadata like image format and resolution.

**Example Request:**

```json
{
  "image_url": "https://example.com/image.jpg"
}
```

**Example Response:**

```json
{
  "width": 1024,
  "height": 768,
  "format": "JPEG"
}
```

---

### Calling the Microservice from AWS Glue

In your Glue script:

```python
import requests
import os

response = requests.post(
    os.getenv("LIGHTSAIL_API"),
    json={"image_url": "https://example.com/image.jpg"}
)
print(response.json())
```

---

### Security and Best Practices

- API keys and database credentials are managed with AWS Secrets Manager
- HTTPS is recommended for the Lightsail microservice (via NGINX and Let's Encrypt)
- AWS IAM roles follow least privilege principles
- Sensitive files (like `.env`) are excluded from version control

---

### Notes

- IAM roles used by AWS Glue must have permission to access secrets from Secrets Manager
- Glue jobs are configured to run daily, but this can be adjusted using triggers or EventBridge
- Logs can be monitored through CloudWatch, and alerts can be sent using SNS (optional)
