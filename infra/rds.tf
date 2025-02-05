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

# PostgreSQL RDS Instance
module "postgres_db" {
  source = "terraform-aws-modules/rds/aws"

  identifier            = "${local.name}-postgres"
  engine                = "postgres"
  engine_version        = "16"
  instance_class        = "db.t4g.medium"
  family                = "postgres16"
  allocated_storage     = 10
  max_allocated_storage = 20

  db_name  = local.db_name
  username = "postgres"
  port     = 5432
  # for POC only
  manage_master_user_password = false
  password                    = var.db_password

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  publicly_accessible = true

  parameters = [
    {
      name  = "autovacuum"
      value = "1"
    },
    {
      name  = "client_encoding"
      value = "utf8"
    },
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  tags = local.tags
}

# MySQL RDS Instance
module "mysql_db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-mysql"

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t4g.medium"

  allocated_storage     = 10
  max_allocated_storage = 20

  db_name  = local.db_name
  username = "debezium"
  port     = 3306
  # for POC only
  manage_master_user_password = false
  password                    = var.db_password

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  parameters = [
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "pending-reboot"
    }
  ]

  tags = local.tags
}

# Outputs for PostgreSQL and MySQL
output "postgres_db_instance_address" {
  value = module.postgres_db.db_instance_address
}

output "mysql_db_instance_address" {
  value = module.mysql_db.db_instance_address
}
