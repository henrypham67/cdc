# Connect to the datalake: Kafka Connect and Trino
data "aws_iam_policy_document" "pod_identity_trust_relationship" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "iceberg_access" {
  name               = "DatalakeIcebergAccess"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_relationship.json
}

resource "aws_iam_policy" "iceberg_access" {
  policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
                ,"s3:GetObject"
                ,"s3:ListBucket"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  }
  EOF
  name   = "DatalakeIcebergAccess"
}

resource "aws_iam_role_policy_attachment" "iceberg_access" {
  policy_arn = aws_iam_policy.iceberg_access.arn
  role       = aws_iam_role.iceberg_access.name
}

# Kafka Connect Iceberg Sync Connector
resource "aws_eks_pod_identity_association" "iceberg_kafka_connector" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kafka"
  service_account = "debezium-connect-cluster-connect"
  role_arn        = aws_iam_role.iceberg_access.arn
}

resource "aws_s3_bucket" "iceberg_bucket" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_glue_catalog_database" "test_table" {
  name         = "test"
  location_uri = "s3://${aws_s3_bucket.iceberg_bucket.id}"
}