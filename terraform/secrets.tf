############################
# 🚀 NASA API Key Secret
############################
resource "aws_secretsmanager_secret" "nasa_api_key" {
  name        = "nasa_api_key"
  description = "NASA API key for Glue ETL"
}

resource "aws_secretsmanager_secret_version" "nasa_api_key_version" {
  secret_id     = aws_secretsmanager_secret.nasa_api_key.id
  secret_string = jsonencode({
    NASA_API_KEY = "XgYImguXI4JbgdZTBe5VCkVCAQLaKj6asttiFDMr"
  })
}

############################
# 🛠 Database Credentials Secret
############################
resource "aws_secretsmanager_secret" "nasa_etl_db_credentials" {
  name        = "nasa_etl_db_credentials"
  description = "PostgreSQL credentials for NASA ETL pipeline"
}

resource "aws_secretsmanager_secret_version" "nasa_etl_db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.nasa_etl_db_credentials.id
  secret_string = jsonencode({
    DB_USER = "nasaadmin",
    DB_PASS = "admin1234",
    DB_HOST = "terraform-20250329172906657100000001.coj2i6uw41gd.us-east-1.rds.amazonaws.com:5432",
    DB_NAME = "nasadb"
  })
}
