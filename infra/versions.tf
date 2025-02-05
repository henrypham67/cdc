terraform {
  required_version = ">= 1.10"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
  }
}