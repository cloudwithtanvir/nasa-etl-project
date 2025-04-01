provider "aws" {
  region = var.aws_region
}

####################
# IAM Role for Glue
####################
resource "aws_iam_role" "glue_service" {
  name = "glue_etl_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.glue_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

####################
# Secrets Manager
####################
resource "aws_secretsmanager_secret" "nasa_api_key" {
  name = "nasa_api_key"
}

resource "aws_secretsmanager_secret_version" "nasa_api_key_value" {
  secret_id     = aws_secretsmanager_secret.nasa_api_key.id
  secret_string = jsonencode({
    NASA_API_KEY = var.nasa_api_key
  })
}

resource "aws_secretsmanager_secret" "nasa_etl_db_credentials" {
  name = "nasa_etl_db_credentials"
}

resource "aws_secretsmanager_secret_version" "nasa_etl_db_credentials_value" {
  secret_id     = aws_secretsmanager_secret.nasa_etl_db_credentials.id
  secret_string = jsonencode({
    DB_USER = var.db_user,
    DB_PASS = var.db_pass,
    DB_HOST = aws_db_instance.nasa_rds.address,
    DB_NAME = var.db_name
  })
}

resource "aws_iam_policy" "glue_secret_policy" {
  name = "glue_secret_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          aws_secretsmanager_secret.nasa_api_key.arn,
          aws_secretsmanager_secret.nasa_etl_db_credentials.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secret_policy" {
  role       = aws_iam_role.glue_service.name
  policy_arn = aws_iam_policy.glue_secret_policy.arn
}

####################
# RDS PostgreSQL
####################
resource "aws_db_instance" "nasa_rds" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_pass
  skip_final_snapshot  = true
  publicly_accessible  = true
}

####################
# AWS Glue Job
####################
resource "aws_glue_job" "nasa_etl" {
  name     = "nasa-etl-job"
  role_arn = aws_iam_role.glue_service.arn

  default_arguments = {
    "--nasa_secret_arn" = aws_secretsmanager_secret.nasa_api_key.arn
    "--secret_arn"      = aws_secretsmanager_secret.nasa_etl_db_credentials.arn
  }

  command {
    name            = "glueetl"
    script_location = var.script_s3_path
    python_version  = "3"
  }

  max_capacity = 2.0
}

####################
# AWS Lightsail (Optional)
####################
resource "aws_lightsail_instance" "etl_service" {
  name              = "nasa-etl-microservice"
  availability_zone = var.availability_zone
  blueprint_id      = var.lightsail_blueprint
  bundle_id         = var.lightsail_bundle
  depends_on        = [aws_db_instance.nasa_rds]
}

####################
# Outputs
####################
output "rds_endpoint" {
  value = aws_db_instance.nasa_rds.endpoint
}

output "lightsail_ip" {
  value = aws_lightsail_instance.etl_service.public_ip_address
}
