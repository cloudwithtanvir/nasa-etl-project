variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "db_user" {
  description = "Username for the RDS database"
  type        = string
}

variable "db_pass" {
  description = "Password for the RDS database"
  type        = string
}

variable "nasa_api_key" {
  description = "API key for NASA APIs"
  type        = string
}

variable "script_s3_path" {
  description = "S3 path for the Glue ETL script"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the Lightsail instance"
  default     = "us-east-1a"
}

variable "lightsail_blueprint" {
  description = "Lightsail blueprint ID (e.g., ubuntu_20_04)"
  default     = "ubuntu_20_04"
}

variable "lightsail_bundle" {
  description = "Lightsail bundle ID (e.g., nano_2_0)"
  default     = "nano_2_0"
}
