module "eks" {
  depends_on = [module.vpc]

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                   = local.name
  cluster_version                = "1.32"
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    worker_nodes = { # node group name
      ami_type      = "AL2_x86_64"
      instance_type = "t3.medium"

      min_size     = 3
      max_size     = 5
      desired_size = 4
      iam_role_additional_policies = {
        ebs_policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  tags = local.tags
}

data "aws_eks_cluster_auth" "this" {
  depends_on = [module.eks]
  name       = local.name
}