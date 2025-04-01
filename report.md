# Project Report – NASA ETL Pipeline

## Overview

This project implements a fully automated ETL pipeline that integrates data from multiple NASA APIs. The pipeline extracts, transforms, and loads the data into a PostgreSQL database hosted on AWS RDS. An enrichment microservice is deployed on AWS Lightsail to analyze image metadata. The entire process is automated using AWS Glue, and the infrastructure is provisioned using Terraform.

## Objectives

- Extract data from:
  - NASA Astronomy Picture of the Day (APOD)
  - Near-Earth Object Web Service (NeoWs)
  - Mars Rover Photos API
- Clean, normalize, and merge the datasets
- Load the final data into AWS RDS
- Deploy an image analysis microservice on AWS Lightsail
- Automate the ETL pipeline using AWS Glue
- Manage secrets securely with AWS Secrets Manager

## APIs Used

| API                  | Description                                      |
|----------------------|--------------------------------------------------|
| APOD API             | Daily astronomy media, titles, and explanations |
| NeoWs API            | Asteroid data including approach dates and size |
| Mars Rover Photos API| Images taken by the Curiosity rover on Mars     |

## Tools and Technologies

- Python (`requests`, `pandas`, `sqlalchemy`, `Pillow`, `Flask`, `gunicorn`)
- AWS Glue (ETL automation)
- AWS RDS (PostgreSQL)
- AWS Lightsail (microservice hosting)
- AWS Secrets Manager (secure credential storage)
- AWS S3 (for script storage)
- Terraform (Infrastructure as Code)

## Challenges and Solutions

### 1. Secure Secret Management  
Storing credentials directly in the code was avoided by using AWS Secrets Manager. IAM roles were configured to allow Glue jobs to access secrets securely.

### 2. Multiple API Formats  
Each NASA API returned data in a different format. Separate extraction functions were created, and data was normalized to ISO date formats and consistent naming conventions.

### 3. Data Enrichment  
To analyze images from the APOD and Mars Rover APIs, a Flask microservice was deployed on Lightsail. It receives image URLs and returns format, resolution, and other metadata using the Pillow library.

### 4. Glue and Lightsail Integration  
To connect Glue with the microservice, Lightsail was configured with a public IP and firewall rules. API calls were made from Glue using `requests`.

### 5. Automation and Scheduling  
Glue Triggers were configured to run the ETL pipeline daily. Logging was enabled via CloudWatch for monitoring and debugging.

## Database Schema

- `apod_data`: Stores APOD image metadata
- `neo_objects`: Near-Earth object data
- `mars_photos`: Mars rover image metadata
- `enriched_results`: Output from the Lightsail microservice

Primary and foreign keys were used to support efficient joins and filtering.

## Deployment Summary

- Terraform provisions RDS, S3, IAM roles, and Glue jobs
- Python scripts are uploaded to S3 for Glue jobs to run
- Microservice is deployed on Lightsail using NGINX and Gunicorn
- `.env` is used locally, while Secrets Manager is used in production

## Future Improvements

- Containerize the microservice using Docker
- Add error notification using SNS
- Extend enrichment with computer vision (OpenCV or TensorFlow)
- Visualize data using QuickSight or a frontend dashboard

## Completion Summary

- [x] Data extracted from three NASA APIs
- [x] Cleaned and merged data into a unified schema
- [x] Data loaded into AWS RDS (PostgreSQL)
- [x] Image enrichment service deployed on Lightsail
- [x] Automated daily ETL with AWS Glue
- [x] Secrets securely managed
- [x] Documentation and Infrastructure as Code provided



## Author

Tanvir Ahmed  
Cloud & Data Engineer  
