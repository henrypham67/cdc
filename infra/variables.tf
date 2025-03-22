variable "db_password" {
  description = "Password for database connections"
  type        = string
  sensitive   = true
}

variable "docker_hub" {
  description = "Docker Hub credentials"
  type        = string
  sensitive   = true
} 