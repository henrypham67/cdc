terraform {
  required_version = ">= 1.10"

  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.92.0"
    }
  }
}