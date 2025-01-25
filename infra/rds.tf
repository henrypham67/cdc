locals {
  name   = "debezium-demo"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_version = "1.31"

  tags = {
    Name    = local.name
    Example = local.name
  }
}



data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                   = "postgres"
  engine_version           = "16"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  instance_class           = "db.t4g.medium"
  family                   = "postgres16"

  allocated_storage     = 20
  max_allocated_storage = 50

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = "postgres"
  username = "postgres"
  password = "nZh2mXMD9uRrXfJctV71" # for POC only
  port     = 5432

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  publicly_accessible = true

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    },
    {
      name  = "rds.logical_replication"
      value = "1"
      apply_method = "pending-reboot"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  cloudwatch_log_group_tags = {
    "Sensitive" = "high"
  }
}

output "db_instance_address" {
  value = module.db.db_instance_address
}
