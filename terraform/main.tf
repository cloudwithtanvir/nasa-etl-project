provider "aws" {
  region = "us-east-1"
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
# RDS PostgreSQL
####################
resource "aws_db_instance" "nasa_rds" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  db_name              = "nasadb"
  username             = "nasaadmin"
  password             = "admin1234"
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
    script_location = "s3://nasa-etl-pipeline-bucket/scripts/etl_glue_job.py"
    python_version  = "3"
  }

  max_capacity = 2.0
}

####################
# AWS Lightsail (Optional)
####################
resource "aws_lightsail_instance" "etl_service" {
  name              = "nasa-etl-microservice"
  availability_zone = "us-east-1a"
  blueprint_id      = "ubuntu_20_04"
  bundle_id         = "nano_2_0"
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
