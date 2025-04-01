# main.tf
resource "aws_secretsmanager_secret" "nasa_api_key" {
  name        = "nasa_api_key"
  description = "NASA API key for Glue ETL"
}

resource "aws_secretsmanager_secret_version" "nasa_api_key_version" {
  secret_id     = aws_secretsmanager_secret.nasa_api_key.id
  secret_string = jsonencode({
    NASA_API_KEY = var.nasa_api_key
  })
}

resource "aws_secretsmanager_secret" "nasa_etl_db_credentials" {
  name        = "nasa_etl_db_credentials"
  description = "PostgreSQL credentials for NASA ETL pipeline"
}

resource "aws_secretsmanager_secret_version" "nasa_etl_db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.nasa_etl_db_credentials.id
  secret_string = jsonencode({
    DB_USER = var.db_user,
    DB_PASS = var.db_pass,
    DB_HOST = var.db_host,
    DB_NAME = var.db_name
  })
}
